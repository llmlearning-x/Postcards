import { DataManager } from '../model/DataManager';

export enum ToastType {
  INFO = 'INFO',
  SUCCESS = 'SUCCESS',
  ERROR = 'ERROR',
  WARNING = 'WARNING'
}

export interface ConfirmDialogOptions {
  title: string,
  message: string,
  confirm?: string,
  cancel?: string,
  dangerous?: boolean,
  onConfirm?: () => void,
  onCancel?: () => void
}

class ToastManagerClass {
  private _toastMessage: string = '';
  private _showToast: boolean = false;
  private _toastType: ToastType = ToastType.INFO;
  private _toastTimer: number | undefined = undefined;

  get toastMessage(): string {
    return this._toastMessage;
  }

  set toastMessage(value: string) {
    this._toastMessage = value;
  }

  get showToast(): boolean {
    return this._showToast;
  }

  set showToast(value: boolean) {
    this._showToast = value;
  }

  get toastType(): ToastType {
    return this._toastType;
  }

  set toastType(value: ToastType) {
    this._toastType = value;
  }

  show(message: string, type: ToastType = ToastType.INFO, duration: number = 2000) {
    if (this._toastTimer !== undefined) {
      clearTimeout(this._toastTimer);
    }

    this._toastMessage = message;
    this._toastType = type;
    this._showToast = true;

    this._toastTimer = setTimeout(() => {
      this.hide();
    }, duration);
  }

  hide() {
    this._showToast = false;
    if (this._toastTimer !== undefined) {
      clearTimeout(this._toastTimer);
      this._toastTimer = undefined;
    }
  }

  success(message: string) {
    this.show(message, ToastType.SUCCESS);
  }

  error(message: string) {
    this.show(message, ToastType.ERROR);
  }

  warning(message: string) {
    this.show(message, ToastType.WARNING);
  }

  info(message: string) {
    this.show(message, ToastType.INFO);
  }
}

class ConfirmDialogManagerClass {
  private _isVisible: boolean = false;
  private _title: string = '';
  private _message: string = '';
  private _confirmText: string = '确认';
  private _cancelText: string = '取消';
  private _isDangerous: boolean = false;
  private _onConfirmCallback: (() => void) | undefined = undefined;
  private _onCancelCallback: (() => void) | undefined = undefined;

  get isVisible(): boolean {
    return this._isVisible;
  }

  set isVisible(value: boolean) {
    this._isVisible = value;
  }

  get title(): string {
    return this._title;
  }

  set title(value: string) {
    this._title = value;
  }

  get message(): string {
    return this._message;
  }

  set message(value: string) {
    this._message = value;
  }

  get confirmText(): string {
    return this._confirmText;
  }

  set confirmText(value: string) {
    this._confirmText = value;
  }

  get cancelText(): string {
    return this._cancelText;
  }

  set cancelText(value: string) {
    this._cancelText = value;
  }

  get isDangerous(): boolean {
    return this._isDangerous;
  }

  set isDangerous(value: boolean) {
    this._isDangerous = value;
  }

  show(options: ConfirmDialogOptions) {
    this._title = options.title;
    this._message = options.message;
    this._confirmText = options.confirm ?? '确认';
    this._cancelText = options.cancel ?? '取消';
    this._isDangerous = options.dangerous ?? false;
    this._onConfirmCallback = options.onConfirm;
    this._onCancelCallback = options.onCancel;
    this._isVisible = true;
  }

  hide() {
    this._isVisible = false;
  }

  confirm() {
    this.hide();
    if (this._onConfirmCallback) {
      this._onConfirmCallback();
    }
  }

  cancel() {
    this.hide();
    if (this._onCancelCallback) {
      this._onCancelCallback();
    }
  }
}

class LoadingManagerClass {
  private _isLoading: boolean = false;
  private _message: string = '加载中...';

  get isLoading(): boolean {
    return this._isLoading;
  }

  set isLoading(value: boolean) {
    this._isLoading = value;
  }

  get message(): string {
    return this._message;
  }

  set message(value: string) {
    this._message = value;
  }

  show(message: string = '加载中...') {
    this._message = message;
    this._isLoading = true;
  }

  hide() {
    this._isLoading = false;
  }
}

export const ToastManager = new ToastManagerClass();
export const ConfirmDialogManager = new ConfirmDialogManagerClass();
export const LoadingManager = new LoadingManagerClass();
