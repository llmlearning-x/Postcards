import SwiftUI
import SwiftData
#if canImport(PhotosUI)
import PhotosUI
#endif
#if canImport(CoreLocation)
import CoreLocation
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif
#if canImport(AVFoundation)
import AVFoundation
#endif
#if canImport(Combine)
import Combine
#endif

#if canImport(UIKit)
typealias PlatformImage = UIImage
#elseif canImport(AppKit)
typealias PlatformImage = NSImage
#endif

struct RecordFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Travel.startDate, order: .reverse) private var travels: [Travel]
    @State private var currentStep: RecordStep = .chooseMethod
    @State private var selectedImages: [PlatformImage] = []
    @State private var note = ""
    @State private var locationName = ""
    @State private var resolvedCurrentLocation: CLLocation?
    @State private var resolvedPlacemark: CLPlacemark?
    @State private var hasAttemptedAutoLocation = false
    @State private var isLocating = false
    @State private var locationStatusMessage: String?
    @State private var flowErrorMessage: String?
#if canImport(PhotosUI)
    @State private var isPhotoPickerPresented = false
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
#endif
    
    enum RecordStep {
        case chooseMethod, capture, edit, preview
    }
    
    var body: some View {
        NavigationStack {
            Group {
                switch currentStep {
                case .chooseMethod:
                    ChooseMethodView(onSelect: { method in
                        switch method {
                        case .camera:
                            currentStep = .capture
                        case .photoLibrary:
#if canImport(PhotosUI)
                            isPhotoPickerPresented = true
#else
                            flowErrorMessage = "当前平台不支持相册导入"
#endif
                        case .voice:
                            currentStep = .edit
                        case .text:
                            currentStep = .edit
                        }
                    })
                case .capture:
                    CameraCaptureView(onComplete: { images in
                        selectedImages = images
                        currentStep = .edit
                    })
                case .edit:
                    RecordEditView(
                        images: selectedImages,
                        note: $note,
                        location: $locationName,
                        isLocating: isLocating,
                        locationStatusMessage: locationStatusMessage,
                        onAppearAutofill: {
                            requestLocationAutofill()
                        },
                        onRequestLocation: {
                            requestLocationAutofill(force: true)
                        },
                        onNext: {
                            currentStep = .preview
                        }
                    )
                case .preview:
                    PostcardPreviewView(images: selectedImages, note: note, location: locationName) {
                        savePostcard()
                    }
                }
            }
            .navigationTitle(navigationTitle)
            .toolbar {
                ToolbarItem(placement: toolbarLeadingPlacement) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(PostcardColors.pencilGray)
                }
                
                if currentStep != .chooseMethod {
                    ToolbarItem(placement: toolbarLeadingPlacement) {
                        Button("返回") {
                            goBack()
                        }
                        .foregroundColor(PostcardColors.travelBlue)
                    }
                }
            }
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .alert("操作失败", isPresented: flowErrorAlertIsPresented) {
                Button("知道了", role: .cancel) {}
            } message: {
                Text(flowErrorMessage ?? "请稍后重试")
            }
#if canImport(PhotosUI)
            .photosPicker(
                isPresented: $isPhotoPickerPresented,
                selection: $selectedPhotoItems,
                maxSelectionCount: 6,
                selectionBehavior: .ordered,
                matching: .images
            )
            .onChange(of: selectedPhotoItems) { _, newItems in
                Task {
                    await importSelectedPhotos(from: newItems)
                }
            }
#endif
        }
    }
    
    private var navigationTitle: String {
        switch currentStep {
        case .chooseMethod: return "记录新瞬间"
        case .capture: return "拍摄"
        case .edit: return "编辑"
        case .preview: return "明信片预览"
        }
    }
    
    private func goBack() {
        switch currentStep {
        case .capture: currentStep = .chooseMethod
        case .edit: currentStep = .capture
        case .preview: currentStep = .edit
        default: break
        }
    }

    private var flowErrorAlertIsPresented: Binding<Bool> {
        Binding(
            get: { flowErrorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    flowErrorMessage = nil
                }
            }
        )
    }

    private func savePostcard() {
        let trimmedLocation = locationName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        let placemarkLocation = resolvedPlacemark.map(LocationSnapshot.init)
        let fallbackLocation = ResolvedLocation.resolve(from: trimmedLocation)

        let postcard = Postcard(
            locationName: placemarkLocation?.displayName ?? fallbackLocation.displayName,
            recordedAt: Date()
        )
        postcard.note = trimmedNote.isEmpty ? nil : trimmedNote
        postcard.locationLat = placemarkLocation?.latitude ?? fallbackLocation.latitude
        postcard.locationLng = placemarkLocation?.longitude ?? fallbackLocation.longitude
        postcard.country = placemarkLocation?.country ?? fallbackLocation.country
        postcard.city = placemarkLocation?.city ?? fallbackLocation.city
        postcard.tags = placemarkLocation?.defaultTags ?? fallbackLocation.defaultTags
        postcard.photos = []

        if let currentTravel {
            postcard.travel = currentTravel
            postcard.travelID = currentTravel.id
        }

        do {
            postcard.photos = try LocalMediaStore.save(images: selectedImages)
            if
                let currentTravel,
                (currentTravel.coverImageURL?.isEmpty ?? true),
                let firstPhotoPath = postcard.photos.first
            {
                currentTravel.coverImageURL = firstPhotoPath
                currentTravel.updatedAt = Date()
            }
            modelContext.insert(postcard)
            try modelContext.save()
            dismiss()
        } catch {
            flowErrorMessage = error.localizedDescription
        }
    }

    private var currentTravel: Travel? {
        travels.first { $0.isCurrent } ?? travels.first { $0.status == .ongoing }
    }

    private var toolbarLeadingPlacement: ToolbarItemPlacement {
#if os(iOS)
        .topBarLeading
#else
        .navigation
#endif
    }
}

extension RecordFlowView {
    @MainActor
    fileprivate func requestLocationAutofill(force: Bool = false) {
        if !force {
            guard !hasAttemptedAutoLocation else { return }
            guard locationName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        }
        guard !isLocating else { return }

        hasAttemptedAutoLocation = true
        isLocating = true
        locationStatusMessage = "正在获取当前位置…"

        LocationManager.shared.requestPermission()
        LocationManager.shared.requestSingleLocation()
            .flatMap { location -> AnyPublisher<(CLLocation, CLPlacemark), Error> in
                LocationManager.shared.reverseGeocode(location)
                    .map { (location, $0) }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                isLocating = false
                if case .failure = completion {
                    locationStatusMessage = "未能获取位置，可手动输入地点"
                }
            }, receiveValue: { location, placemark in
                resolvedCurrentLocation = location
                resolvedPlacemark = placemark
                locationName = formatLocationName(from: placemark)
                locationStatusMessage = "已自动识别当前位置"
            })
            .store(in: &LocationManager.shared.cancellables)
    }

    private func formatLocationName(from placemark: CLPlacemark) -> String {
        let preferredParts = [
            placemark.name,
            placemark.locality,
            placemark.subLocality,
            placemark.thoroughfare
        ]
        .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }

        if let firstMeaningful = preferredParts.first {
            return firstMeaningful
        }

        if let country = placemark.country, !country.isEmpty {
            return country
        }

        return "当前位置"
    }
}

private struct LocationSnapshot {
    let displayName: String
    let city: String?
    let country: String?
    let latitude: Double?
    let longitude: Double?
    let defaultTags: [String]

    init(_ placemark: CLPlacemark) {
        displayName = [
            placemark.name,
            placemark.locality,
            placemark.subLocality,
            placemark.thoroughfare
        ]
        .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
        .first(where: { !$0.isEmpty }) ?? "当前位置"

        city = placemark.locality ?? placemark.subAdministrativeArea
        country = placemark.country
        latitude = placemark.location?.coordinate.latitude
        longitude = placemark.location?.coordinate.longitude

        let tagCandidates = [placemark.locality, placemark.country, "旅行"]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        defaultTags = Array(NSOrderedSet(array: tagCandidates)) as? [String] ?? tagCandidates
    }
}

#if canImport(PhotosUI)
extension RecordFlowView {
    @MainActor
    private func importSelectedPhotos(from items: [PhotosPickerItem]) async {
        guard !items.isEmpty else { return }

        var importedImages: [PlatformImage] = []

        for item in items {
            do {
                if
                    let data = try await item.loadTransferable(type: Data.self),
                    let image = PlatformImage(data: data)
                {
                    importedImages.append(image)
                }
            } catch {
                flowErrorMessage = "有图片导入失败，请重试"
            }
        }

        guard !importedImages.isEmpty else {
            flowErrorMessage = flowErrorMessage ?? "未能读取所选照片"
            return
        }

        selectedImages = importedImages
        currentStep = .edit
    }
}
#endif

private struct ResolvedLocation {
    let displayName: String
    let city: String?
    let country: String?
    let latitude: Double?
    let longitude: Double?
    let defaultTags: [String]

    static func resolve(from rawLocation: String) -> ResolvedLocation {
        let trimmed = rawLocation.trimmingCharacters(in: .whitespacesAndNewlines)
        let fallbackName = trimmed.isEmpty ? "未命名地点" : trimmed
        let normalized = fallbackName.lowercased()

        let presets: [(keywords: [String], resolved: ResolvedLocation)] = [
            (
                ["东京塔", "tokyo tower"],
                ResolvedLocation(
                    displayName: fallbackName,
                    city: "东京",
                    country: "日本",
                    latitude: 35.6586,
                    longitude: 139.7454,
                    defaultTags: ["东京", "日本", "旅行"]
                )
            ),
            (
                ["东京", "tokyo"],
                ResolvedLocation(
                    displayName: fallbackName,
                    city: "东京",
                    country: "日本",
                    latitude: 35.6762,
                    longitude: 139.6503,
                    defaultTags: ["东京", "日本", "旅行"]
                )
            ),
            (
                ["京都", "kyoto"],
                ResolvedLocation(
                    displayName: fallbackName,
                    city: "京都",
                    country: "日本",
                    latitude: 35.0116,
                    longitude: 135.7681,
                    defaultTags: ["京都", "日本", "旅行"]
                )
            ),
            (
                ["桂林", "guilin"],
                ResolvedLocation(
                    displayName: fallbackName,
                    city: "桂林",
                    country: "中国",
                    latitude: 25.2740,
                    longitude: 110.2993,
                    defaultTags: ["桂林", "中国", "旅行"]
                )
            )
        ]

        if let matched = presets.first(where: { preset in
            preset.keywords.contains(where: normalized.contains)
        }) {
            return matched.resolved
        }

        return ResolvedLocation(
            displayName: fallbackName,
            city: nil,
            country: nil,
            latitude: nil,
            longitude: nil,
            defaultTags: trimmed.isEmpty ? [] : [fallbackName]
        )
    }
}

// MARK: - Choose Method
struct ChooseMethodView: View {
    enum Method { case camera, voice, text, photoLibrary }
    let onSelect: (Method) -> Void
    
    var body: some View {
            VStack(spacing: 32) {
                Text("选择记录方式")
                    .font(.title2.bold())
                    .foregroundColor(PostcardColors.inkBlack)
            
            HStack(spacing: 20) {
                MethodButton(icon: "camera.fill", title: "拍照", color: PostcardColors.stampRed) {
                    onSelect(.camera)
                }
                .accessibilityIdentifier("RecordMethodCamera")
                MethodButton(icon: "mic.fill", title: "语音", color: PostcardColors.travelBlue) {
                    onSelect(.voice)
                }
                .accessibilityIdentifier("RecordMethodVoice")
                MethodButton(icon: "textformat", title: "文字", color: PostcardColors.forestGreen) {
                    onSelect(.text)
                }
                .accessibilityIdentifier("RecordMethodText")
            }
            
            Button(action: { onSelect(.photoLibrary) }) {
                HStack {
                    Image(systemName: "photo.on.rectangle.angled")
                    Text("从相册导入多张照片")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(PostcardColors.paperBeige)
                .foregroundColor(PostcardColors.inkBlack)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "#E8E4DC"), lineWidth: 1)
                )
            }
            .padding(.horizontal, 32)
            .accessibilityIdentifier("RecordMethodPhotoLibrary")
            
            Spacer()
        }
        .padding(.top, 40)
        .background(PostcardColors.pageBackground)
    }
}

struct MethodButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .frame(width: 72, height: 72)
                    .background(color.opacity(0.1))
                    .foregroundColor(color)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(PostcardColors.inkBlack)
            }
        }
    }
}

// MARK: - Camera Capture
struct CameraCaptureView: View {
    let onComplete: ([PlatformImage]) -> Void
    @StateObject private var camera = CameraService()
    @State private var capturedImages: [PlatformImage] = []
    
    var body: some View {
        ZStack {
            // Camera Preview
            GeometryReader { geo in
                Color.black
                    .overlay(
                        Group {
                            if camera.isReady {
#if canImport(AVFoundation) && canImport(UIKit)
                                CameraPreviewView(session: camera.session)
                                    .frame(width: geo.size.width, height: geo.size.height)
#else
                                CameraPreviewView()
                                    .frame(width: geo.size.width, height: geo.size.height)
#endif
                            }
                        }
                    )
            }
            
            // Controls
            VStack {
                Spacer()
                
                HStack(spacing: 40) {
                    // Gallery preview
                    if let last = capturedImages.last {
                        PlatformImageView(image: last)
                            .scaledToFill()
                            .frame(width: 48, height: 48)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 48, height: 48)
                    }
                    
                    // Shutter
                    Button(action: {
                        camera.capturePhoto()
                            .sink(receiveCompletion: { _ in },
                                  receiveValue: { image in
                                capturedImages.append(image)
                            })
                            .store(in: &camera.cancellables)
                    }) {
                        Circle()
                            .stroke(Color.white, lineWidth: 4)
                            .frame(width: 72, height: 72)
                            .overlay(
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 60, height: 60)
                            )
                    }
                    
                    // Switch / Done
                    if capturedImages.isEmpty {
                        Button(action: { camera.switchCamera() }) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    } else {
                        Button(action: {
                            onComplete(capturedImages)
                        }) {
                            Text("完成")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            camera.checkPermission()
                .sink { granted in
                    if granted {
                        camera.setup()
                    }
                }
                .store(in: &camera.cancellables)
        }
        .onDisappear {
            camera.stop()
        }
    }
}

struct CameraPreviewView: View {
#if canImport(AVFoundation) && canImport(UIKit)
    let session: AVCaptureSession
#endif

    var body: some View {
#if canImport(AVFoundation) && canImport(UIKit)
        CameraPreviewRepresentable(session: session)
#else
        ContentUnavailableView("相机预览不可用", systemImage: "camera.slash")
#endif
    }
}

// MARK: - Record Edit
struct RecordEditView: View {
    let images: [PlatformImage]
    @Binding var note: String
    @Binding var location: String
    let isLocating: Bool
    let locationStatusMessage: String?
    let onAppearAutofill: () -> Void
    let onRequestLocation: () -> Void
    let onNext: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Photo preview
                TabView {
                    ForEach(images.indices, id: \.self) { index in
                        PlatformImageView(image: images[index])
                            .scaledToFit()
                    }
                }
                .frame(height: 300)
#if os(iOS)
                .tabViewStyle(.page)
#endif
                
                // Auto info
                VStack(alignment: .leading, spacing: 12) {
                    InfoRow(icon: "mappin.circle.fill", color: PostcardColors.stampRed, text: location.isEmpty ? "自动识别地点..." : location)
                    InfoRow(icon: "clock", color: PostcardColors.pencilGray, text: Date().formatted())
                    InfoRow(icon: "sun.max.fill", color: PostcardColors.dawnYellow, text: "晴朗 24°C")
                }
                .padding(16)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                TextField("地点名称", text: $location)
                    .padding(12)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "#E8E4DC"), lineWidth: 1)
                    )
                    .accessibilityIdentifier("RecordLocationField")

                Button(action: onRequestLocation) {
                    Label(isLocating ? "定位中…" : "使用当前位置", systemImage: "location.fill")
                        .font(.subheadline.weight(.medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(PostcardColors.postalMint)
                        .foregroundColor(PostcardColors.travelBlue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(isLocating)

                if let locationStatusMessage {
                    Text(locationStatusMessage)
                        .font(.caption)
                        .foregroundColor(PostcardColors.pencilGray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Note input
                TextEditor(text: $note)
                    .frame(minHeight: 80)
                    .padding(12)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(note.isEmpty ? Color(hex: "#E8E4DC") : PostcardColors.stampRed, lineWidth: note.isEmpty ? 1 : 2)
                    )
                    .overlay(
                        Group {
                            if note.isEmpty {
                                Text("写下此刻心情...")
                                    .foregroundColor(PostcardColors.stampGray)
                                    .padding(.leading, 16)
                                    .padding(.top, 20)
                            }
                        },
                        alignment: .topLeading
                    )
                    .accessibilityIdentifier("RecordNoteEditor")
                
                // Tags
                FlowLayout(spacing: 8) {
                    ForEach(["#日本", "#东京", "#旅行"], id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .foregroundColor(PostcardColors.travelBlue)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(PostcardColors.travelBlue.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
                
                Button(action: onNext) {
                    Text("生成明信片")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(PostcardColors.stampRed)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .accessibilityIdentifier("GeneratePostcardButton")
            }
            .padding(16)
        }
        .onAppear(perform: onAppearAutofill)
    }
}

struct InfoRow: View {
    let icon: String
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(text)
                .font(.subheadline)
                .foregroundColor(PostcardColors.inkBlack)
            Spacer()
        }
    }
}

// MARK: - Postcard Preview
struct PostcardPreviewView: View {
    let images: [PlatformImage]
    let note: String
    let location: String
    let onSave: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text("明信片预览")
                .font(.title2.bold())
            
            // Postcard Card
            VStack(alignment: .leading, spacing: 16) {
                if let first = images.first {
                    PlatformImageView(image: first)
                        .scaledToFill()
                        .frame(height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(PostcardColors.stampRed)
                    Text(location.uppercased())
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(PostcardColors.stampRed)
                        .tracking(1)
                }
                
                Text(Date(), style: .date)
                    .font(.caption)
                    .foregroundColor(PostcardColors.pencilGray)
                
                if !note.isEmpty {
                    Text("\"\(note)\"")
                        .font(.body)
                        .foregroundColor(PostcardColors.inkBlack)
                }
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: "#E8E4DC"), lineWidth: 1)
            )
            .padding(.horizontal, 16)
            
            HStack(spacing: 16) {
                Button(action: onSave) {
                    HStack {
                        Image(systemName: "checkmark")
                        Text("保存到时间轴")
                    }
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(PostcardColors.stampRed)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .accessibilityIdentifier("SavePostcardButton")
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("分享")
                    }
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(PostcardColors.paperBeige)
                    .foregroundColor(PostcardColors.stampRed)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(PostcardColors.stampRed, lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 16)
            
            Toggle("同时生成「今日来信」", isOn: .constant(true))
                .padding(.horizontal, 16)
            
            Spacer()
        }
        .padding(.top, 20)
    }
}

#if canImport(AVFoundation) && canImport(UIKit)
private struct CameraPreviewRepresentable: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
#endif

private struct PlatformImageView: View {
    let image: PlatformImage

    var body: some View {
#if canImport(UIKit)
        Image(uiImage: image)
            .resizable()
#elseif canImport(AppKit)
        Image(nsImage: image)
            .resizable()
#endif
    }
}

#Preview {
    RecordFlowView()
}
