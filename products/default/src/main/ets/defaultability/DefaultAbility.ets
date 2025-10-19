import { ConfigurationConstant, UIAbility } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AuthService } from '../services/AuthService';
import { DatabaseHelper } from '../database/DatabaseHelper';

const DOMAIN = 0x0000;

export default class DefaultAbility extends UIAbility {
  onCreate(): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    // 初始化数据库
    try {
      const dbHelper = DatabaseHelper.getInstance(this.context);
      await dbHelper.initDatabase();
      hilog.info(DOMAIN, 'testTag', 'Database initialized');
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to init database: %{public}s', JSON.stringify(err));
    }

    // 检查登录状态，决定加载哪个页面
    let startPage = 'pages/LoginPage';
    try {
      const authService = new AuthService(this.context);
      await authService.init();
      const hasPassword = await authService.hasSetPassword();
      
      // 如果已设置密码，则显示登录页；否则也显示登录页（首次设置密码）
      startPage = 'pages/LoginPage';
      hilog.info(DOMAIN, 'testTag', `Has password: ${hasPassword}, loading ${startPage}`);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to check auth: %{public}s', JSON.stringify(err));
    }

    windowStage.loadContent(startPage, (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}