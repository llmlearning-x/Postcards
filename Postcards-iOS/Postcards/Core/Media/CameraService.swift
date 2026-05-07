import Combine
import Foundation

#if canImport(AVFoundation) && canImport(UIKit)
import AVFoundation
import UIKit

typealias CameraImage = UIImage

final class CameraService: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    @Published var previewLayer: AVCaptureVideoPreviewLayer?
    @Published var photoOutput = AVCapturePhotoOutput()
    @Published var isReady = false
    @Published var error: CameraError?
    
    private var videoDeviceInput: AVCaptureDeviceInput?
    var cancellables = Set<AnyCancellable>()
    private var photoCaptureCompletion: ((Result<UIImage, CameraError>) -> Void)?
    
    enum CameraError: Error, LocalizedError {
        case permissionDenied
        case setupFailed
        case captureFailed
        case noCamera
        
        var errorDescription: String? {
            switch self {
            case .permissionDenied: return "相机权限被拒绝"
            case .setupFailed: return "相机初始化失败"
            case .captureFailed: return "拍照失败"
            case .noCamera: return "设备没有相机"
            }
        }
    }
    
    func checkPermission() -> AnyPublisher<Bool, Never> {
        Future { promise in
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                promise(.success(true))
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    promise(.success(granted))
                }
            case .denied, .restricted:
                promise(.success(false))
            @unknown default:
                promise(.success(false))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func setup() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            error = .noCamera
            return
        }
        
        do {
            session.beginConfiguration()
            
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
                videoDeviceInput = input
            }
            
            if session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
                photoOutput.isHighResolutionCaptureEnabled = true
            }
            
            session.commitConfiguration()
            isReady = true
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.session.startRunning()
            }
            
        } catch {
            self.error = .setupFailed
        }
    }
    
    func capturePhoto() -> AnyPublisher<UIImage, CameraError> {
        Future { [weak self] promise in
            guard let self = self else { return }
            
            let settings = AVCapturePhotoSettings()
            settings.isHighResolutionPhotoEnabled = true
            
            self.photoCaptureCompletion = { result in
                switch result {
                case .success(let image): promise(.success(image))
                case .failure(let error): promise(.failure(error))
                }
            }
            
            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
        .eraseToAnyPublisher()
    }
    
    func stop() {
        session.stopRunning()
    }
    
    func switchCamera() {
        guard let currentInput = videoDeviceInput else { return }
        
        let newPosition: AVCaptureDevice.Position = currentInput.device.position == .back ? .front : .back
        guard let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition) else { return }
        
        do {
            session.beginConfiguration()
            session.removeInput(currentInput)
            
            let newInput = try AVCaptureDeviceInput(device: newDevice)
            if session.canAddInput(newInput) {
                session.addInput(newInput)
                videoDeviceInput = newInput
            }
            session.commitConfiguration()
        } catch {
            self.error = .setupFailed
        }
    }
}

extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            photoCaptureCompletion?(.failure(.captureFailed))
            return
        }
        
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            photoCaptureCompletion?(.failure(.captureFailed))
            return
        }
        
        photoCaptureCompletion?(.success(image))
        photoCaptureCompletion = nil
    }
}
#else
#if canImport(AppKit)
import AppKit
typealias CameraImage = NSImage
#endif

final class CameraService: ObservableObject {
    @Published var isReady = false
    @Published var error: CameraError?
    var cancellables = Set<AnyCancellable>()

    enum CameraError: Error, LocalizedError {
        case unsupported

        var errorDescription: String? {
            "当前预览环境不支持相机"
        }
    }

    func checkPermission() -> AnyPublisher<Bool, Never> {
        Just(false).eraseToAnyPublisher()
    }

    func setup() {}

    func capturePhoto() -> AnyPublisher<CameraImage, CameraError> {
        Fail(error: .unsupported).eraseToAnyPublisher()
    }

    func stop() {}

    func switchCamera() {}
}
#endif
