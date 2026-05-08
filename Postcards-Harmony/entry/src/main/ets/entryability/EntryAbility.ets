import { AbilityConstant, UIAbility, Want, Context } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { DataManager } from '../model/DataManager';

export let context: Context | null = null;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    context = this.context;
    DataManager.init();
  }

  onDestroy(): void {
    context = null;
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index').catch(() => {});
  }

  onWindowStageDestroy(): void {
  }

  onForeground(): void {
  }

  onBackground(): void {
  }
}
