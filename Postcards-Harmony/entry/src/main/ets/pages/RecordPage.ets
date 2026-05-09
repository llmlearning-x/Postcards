import router from '@ohos.router';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { cameraPicker, camera } from '@kit.CameraKit';
import { fileIo as fs, fileUri } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { DataManager } from '../model/DataManager';
import { Travel } from '../model/Travel';
import { Postcard } from '../model/Postcard';
import { Colors } from '../components/Colors';
import { PostalStampSeal } from '../components/PostalComponents';

enum RecordStep {
  CHOOSE_METHOD,
  EDIT,
  PREVIEW
}

@Entry
@Component
struct RecordPage {
  @State currentStep: RecordStep = RecordStep.CHOOSE_METHOD;
  @State selectedImages: string[] = [];
  @State note: string = '';
  @State locationName: string = '';
  @State isLocating: boolean = false;
  @State locationStatusMessage: string = '';
  @State flowErrorMessage: string = '';
  @State showErrorDialog: boolean = false;
  @State toggleOn: boolean = true;

  private get currentTravel(): Travel | undefined {
    return DataManager.currentTravel;
  }

  build() {
    Column() {
      // Toolbar
      Row() {
        Button('取消')
          .fontSize(16)
          .fontColor(Colors.pencilGray)
          .backgroundColor('transparent')
          .onClick(() => {
            router.back();
          })

        Blank()

        Text(this.navigationTitle)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.inkBlack)

        Blank()

        if (this.currentStep !== RecordStep.CHOOSE_METHOD) {
          Button('返回')
            .fontSize(16)
            .fontColor(Colors.travelBlue)
            .backgroundColor('transparent')
            .onClick(() => this.goBack())
        } else {
          Button('')
            .width(40)
            .backgroundColor('transparent')
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .height(56)

      // Content
      if (this.currentStep === RecordStep.CHOOSE_METHOD) {
        ChooseMethodView({
          onSelectCamera: () => this.openCamera(),
          onSelectPhotoLibrary: () => this.openPhotoPicker(),
          onSelectVoice: () => { this.currentStep = RecordStep.EDIT; },
          onSelectText: () => { this.currentStep = RecordStep.EDIT; }
        })
      } else if (this.currentStep === RecordStep.EDIT) {
        RecordEditView({
          images: this.selectedImages,
          note: $note,
          location: $locationName,
          isLocating: this.isLocating,
          locationStatusMessage: this.locationStatusMessage,
          onRequestLocation: () => this.requestLocation(),
          onNext: () => { this.currentStep = RecordStep.PREVIEW; }
        })
      } else if (this.currentStep === RecordStep.PREVIEW) {
        PostcardPreviewView({
          images: this.selectedImages,
          note: this.note,
          location: this.locationName,
          onSave: () => this.savePostcard()
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.pageBackground)

    if (this.showErrorDialog) {
      ErrorDialog({
        message: this.flowErrorMessage,
        onClose: () => { this.showErrorDialog = false; }
      })
    }
  }

  private get navigationTitle(): string {
    switch (this.currentStep) {
      case RecordStep.CHOOSE_METHOD: return '记录新瞬间';
      case RecordStep.EDIT: return '编辑';
      case RecordStep.PREVIEW: return '明信片预览';
      default: return '';
    }
  }

  private goBack() {
    switch (this.currentStep) {
      case RecordStep.EDIT:
        this.currentStep = RecordStep.CHOOSE_METHOD;
        break;
      case RecordStep.PREVIEW:
        this.currentStep = RecordStep.EDIT;
        break;
    }
  }

  private async openCamera() {
    try {
      const pickerProfile: cameraPicker.PickerProfile = {
        cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK
      };
      const pickerResult = await cameraPicker.pick(
        getContext(this) as common.UIAbilityContext,
        [cameraPicker.PickerMediaType.PHOTO],
        pickerProfile
      );
      if (pickerResult && pickerResult.resultCode === 0 && pickerResult.resultUri) {
        const sandboxUri = await this.copyToSandbox(pickerResult.resultUri);
        if (sandboxUri) {
          this.selectedImages = [sandboxUri];
          this.currentStep = RecordStep.EDIT;
        }
      }
    } catch (e: Error) {
      this.flowErrorMessage = '相机启动失败';
      this.showErrorDialog = true;
    }
  }

  private async openPhotoPicker() {
    try {
      const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 6;
      const photoPicker = new photoAccessHelper.PhotoViewPicker();
      const result = await photoPicker.select(photoSelectOptions);
      if (result.photoUris && result.photoUris.length > 0) {
        const sandboxUris: string[] = [];
        for (const uri of result.photoUris) {
          const sandboxUri = await this.copyToSandbox(uri);
          if (sandboxUri) {
            sandboxUris.push(sandboxUri);
          }
        }
        if (sandboxUris.length > 0) {
          this.selectedImages = sandboxUris;
          this.currentStep = RecordStep.EDIT;
        }
      }
    } catch (e: Error) {
      this.flowErrorMessage = '相册访问失败';
      this.showErrorDialog = true;
    }
  }

  private async copyToSandbox(sourceUri: string): Promise<string | null> {
    try {
      const ctx = getContext(this) as common.UIAbilityContext;
      const rand = Date.now() % 1000000;
      const fileName = `img_${Date.now()}_${rand}.jpg`;
      const destPath = `${ctx.filesDir}/${fileName}`;

      const srcFile = fs.openSync(sourceUri, fs.OpenMode.READ_ONLY);
      fs.copyFileSync(srcFile.fd, destPath);
      fs.closeSync(srcFile);

      return fileUri.getUriFromPath(destPath);
    } catch (e: Error) {
      console.error('Copy to sandbox failed', e);
      return null;
    }
  }

  private requestLocation() {
    this.isLocating = true;
    this.locationStatusMessage = '正在获取当前位置…';
    // Simulate location
    setTimeout(() => {
      this.isLocating = false;
      this.locationName = '当前位置';
      this.locationStatusMessage = '已自动识别当前位置';
    }, 1500);
  }

  private formatDateTime(d: Date): string {
    const pad = (n: number) => n.toString().padStart(2, '0');
    return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}`;
  }

  private formatDateOnly(d: Date): string {
    const pad = (n: number) => n.toString().padStart(2, '0');
    return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;
  }

  private savePostcard() {
    const trimmedLocation = this.locationName.trim();
    const trimmedNote = this.note.trim();

    const postcard = new Postcard(trimmedLocation.length > 0 ? trimmedLocation : '未命名地点', Date.now());
    postcard.note = trimmedNote.length > 0 ? trimmedNote : null;
    postcard.photos = this.selectedImages;
    postcard.weatherCondition = '晴';
    postcard.weatherTemp = 24;
    postcard.tags = trimmedLocation.length > 0 ? [trimmedLocation, '旅行'] : ['旅行'];

    const current = DataManager.currentTravel;
    if (current) {
      postcard.travelID = current.id;
      postcard.city = current.destination;
      postcard.country = '中国';
    }

    DataManager.addPostcard(postcard);

    // Update travel cover
    if (current && !current.coverImageURL && this.selectedImages.length > 0) {
      current.coverImageURL = this.selectedImages[0];
      DataManager.updateTravel(current);
    }

    router.back();
  }
}

@Component
struct ChooseMethodView {
  onSelectCamera?: () => void;
  onSelectPhotoLibrary?: () => void;
  onSelectVoice?: () => void;
  onSelectText?: () => void;

  build() {
    Column({ space: 32 }) {
      Text('选择记录方式')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(Colors.inkBlack)

      Row({ space: 20 }) {
        MethodButton({ icon: '📷', title: '拍照', color: Colors.stampRed, action: this.onSelectCamera })
        MethodButton({ icon: '🎙', title: '语音', color: Colors.travelBlue, action: this.onSelectVoice })
        MethodButton({ icon: '📝', title: '文字', color: Colors.forestGreen, action: this.onSelectText })
      }

      Button() {
        Row({ space: 8 }) {
          Text('🖼')
            .fontSize(18)
          Text('从相册导入多张照片')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding({ top: 16, bottom: 16 })
        .fontColor(Colors.inkBlack)
      }
      .type(ButtonType.Normal)
      .borderRadius(12)
      .backgroundColor(Colors.paperBeige)
      .border({ width: 1, color: '#E8E4DC', radius: 12 })
      .margin({ left: 32, right: 32 })
      .onClick(() => { if (this.onSelectPhotoLibrary) this.onSelectPhotoLibrary(); })

      Blank()
    }
    .padding({ top: 40 })
    .width('100%')
    .layoutWeight(1)
  }
}

@Component
struct MethodButton {
  icon: string = '';
  title: string = '';
  color: ResourceColor = Colors.travelBlue;
  action?: () => void;

  build() {
    Button() {
      Column({ space: 12 }) {
        Text(this.icon)
          .fontSize(32)
          .width(72)
          .height(72)
          .textAlign(TextAlign.Center)
          .fontColor(this.color)
          .backgroundColor('rgba(0,0,0,0.03)')
          .borderRadius(16)
        Text(this.title)
          .fontSize(14)
          .fontColor(Colors.inkBlack)
      }
    }
    .type(ButtonType.Normal)
    .backgroundColor('transparent')
    .onClick(() => { if (this.action) this.action(); })
  }
}

@Component
struct RecordEditView {
  images: string[] = [];
  @Link note: string;
  @Link location: string;
  isLocating: boolean = false;
  locationStatusMessage: string = '';
  onRequestLocation?: () => void;
  onNext?: () => void;

  build() {
    Scroll() {
      Column({ space: 24 }) {
        // Photo preview
        if (this.images.length > 0) {
          Swiper() {
            ForEach(this.images, (uri: string) => {
              Image(uri)
                .width('100%')
                .height(300)
                .objectFit(ImageFit.Cover)
                .borderRadius(12)
            })
          }
          .height(300)
          .indicator(true)
        }

        // Auto info
        Column({ space: 12 }) {
          InfoRow({ icon: '📍', color: Colors.stampRed, text: this.location.length === 0 ? '自动识别地点...' : this.location })
          InfoRow({ icon: '🕐', color: Colors.pencilGray, text: this.formatDateTime(new Date()) })
          InfoRow({ icon: '☀', color: Colors.dawnYellow, text: '晴朗 24°C' })
        }
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius(12)
        .width('100%')

        TextInput({ placeholder: '地点名称', text: $$location })
          .placeholderColor(Colors.stampGray)
          .padding(12)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .border({ width: 1, color: '#E8E4DC', radius: 12 })
          .width('100%')

        Button() {
          Row({ space: 4 }) {
            Text('📍')
            Text(this.isLocating ? '定位中…' : '使用当前位置')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .padding({ top: 12, bottom: 12 })
          .fontColor(Colors.travelBlue)
        }
        .type(ButtonType.Normal)
        .borderRadius(12)
        .backgroundColor(Colors.postalMint)
        .width('100%')
        .enabled(!this.isLocating)
        .onClick(() => { if (this.onRequestLocation) this.onRequestLocation(); })

        if (this.locationStatusMessage.length > 0) {
          Text(this.locationStatusMessage)
            .fontSize(12)
            .fontColor(Colors.pencilGray)
            .width('100%')
        }

        // Note input
        TextArea({ placeholder: '写下此刻心情...', text: $$note })
          .placeholderColor(Colors.stampGray)
          .height(120)
          .padding(12)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .border({
            width: this.note.length === 0 ? 1 : 2,
            color: this.note.length === 0 ? '#E8E4DC' : Colors.stampRed,
            radius: 12
          })
          .width('100%')

        // Tags
        Flex({ wrap: FlexWrap.Wrap, space: { main: { value: 8, unit: LengthUnit.VP } } }) {
          ForEach(['#日本', '#东京', '#旅行'], (tag: string) => {
            Text(tag)
              .fontSize(12)
              .fontColor(Colors.travelBlue)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .backgroundColor('rgba(15,93,73,0.08)')
              .borderRadius(6)
          })
        }
        .width('100%')

        Button('生成明信片')
          .fontSize(16)
          .fontWeight(FontWeight.SemiBold)
          .fontColor(Color.White)
          .width('100%')
          .height(50)
          .backgroundColor(Colors.stampRed)
          .borderRadius(12)
          .onClick(() => { if (this.onNext) this.onNext(); })
      }
      .padding(16)
      .width('100%')
    }
    .layoutWeight(1)
  }
}

@Component
struct InfoRow {
  icon: string = '';
  color: ResourceColor = Colors.inkBlack;
  text: string = '';

  build() {
    Row({ space: 8 }) {
      Text(this.icon)
        .fontColor(this.color)
      Text(this.text)
        .fontSize(14)
        .fontColor(Colors.inkBlack)
      Blank()
    }
    .width('100%')
  }
}

@Component
struct PostcardPreviewView {
  images: string[] = [];
  note: string = '';
  location: string = '';
  onSave?: () => void;

  build() {
    Column({ space: 24 }) {
      Text('明信片预览')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)

      // Postcard Card
      Column({ space: 16 }) {
        if (this.images.length > 0) {
          Image(this.images[0])
            .width('100%')
            .height(220)
            .objectFit(ImageFit.Cover)
            .borderRadius(12)
        }

        Row({ space: 4 }) {
          Text('📍')
            .fontColor(Colors.stampRed)
          Text(this.location.toUpperCase())
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontFamily('sans-serif')
            .fontColor(Colors.stampRed)
            .letterSpacing(1)
        }

        Text(this.formatDateOnly(new Date()))
          .fontSize(12)
          .fontColor(Colors.pencilGray)

        if (this.note.length > 0) {
          Text(`"${this.note}"`)
            .fontSize(16)
            .fontColor(Colors.inkBlack)
        }
      }
      .padding(16)
      .width('100%')
      .backgroundColor(Color.White)
      .borderRadius(16)
      .shadow({ radius: 12, color: 'rgba(0,0,0,0.08)', offsetY: 4 })
      .border({ width: 1, color: '#E8E4DC', radius: 16 })
      .padding({ left: 16, right: 16 })

      Row({ space: 16 }) {
        Button() {
          Row({ space: 4 }) {
            Text('✓')
            Text('保存到时间轴')
          }
          .fontSize(16)
          .fontWeight(FontWeight.SemiBold)
          .fontColor(Color.White)
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .padding({ top: 14, bottom: 14 })
        }
        .type(ButtonType.Normal)
        .borderRadius(12)
        .backgroundColor(Colors.stampRed)
        .layoutWeight(1)
        .onClick(() => { if (this.onSave) this.onSave(); })

        Button() {
          Row({ space: 4 }) {
            Text('↗')
            Text('分享')
          }
          .fontSize(16)
          .fontWeight(FontWeight.SemiBold)
          .fontColor(Colors.stampRed)
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .padding({ top: 14, bottom: 14 })
        }
        .type(ButtonType.Normal)
        .borderRadius(12)
        .backgroundColor(Colors.paperBeige)
        .border({ width: 1, color: Colors.stampRed, radius: 12 })
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 16, right: 16 })

      Toggle({ type: ToggleType.Switch, isOn: $toggleOn })
        .padding({ left: 16, right: 16 })

      Blank()
    }
    .padding({ top: 20 })
    .layoutWeight(1)
  }
}

@Component
struct ErrorDialog {
  message: string = '';
  onClose?: () => void;

  build() {
    Stack() {
      Column() {
        Column({ space: 16 }) {
          Text('操作失败')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(Colors.inkBlack)
          Text(this.message)
            .fontSize(14)
            .fontColor(Colors.pencilGray)
            .textAlign(TextAlign.Center)

          Button('知道了')
            .fontSize(16)
            .fontColor(Color.White)
            .backgroundColor(Colors.travelBlue)
            .borderRadius(8)
            .padding({ left: 24, right: 24, top: 10, bottom: 10 })
            .onClick(() => { if (this.onClose) this.onClose(); })
        }
        .padding(24)
        .backgroundColor(Colors.cardBackground)
        .borderRadius(16)
        .shadow({ radius: 20, color: 'rgba(0,0,0,0.2)', offsetY: 8 })
        .margin({ left: 40, right: 40 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor('rgba(0,0,0,0.4)')
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
  }
}
