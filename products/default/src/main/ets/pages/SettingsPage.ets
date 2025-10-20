import { router } from '@kit.ArkUI';
import { AuthService } from '../services/AuthService';
import { AppTheme } from '../theme/AppTheme';
import { promptAction } from '@kit.ArkUI';
import { Logger } from '../../../common/src/main/ets/utils/Logger';

const logger = new Logger();

@Entry
@Component
struct SettingsPage {
  @State biometricEnabled: boolean = false;
  @State biometricSupported: boolean = false;
  private authService: AuthService = new AuthService(getContext(this));

  async aboutToAppear() {
    this.biometricEnabled = await this.authService.isBiometricEnabled();
    this.biometricSupported = await this.authService.checkBiometricSupport();
  }

  /**
   * 修改密码
   */
  showChangePasswordDialog() {
    promptAction.showDialog({
      title: '修改密码',
      message: '请前往登录页面重新设置密码',
      buttons: [
        { text: '取消', color: AppTheme.TEXT_SECONDARY },
        { text: '确定', color: AppTheme.PRIMARY_COLOR }
      ]
    }).then((result) => {
      if (result.index === 1) {
        router.replaceUrl({
          url: 'pages/LoginPage'
        }).catch((err: Error) => {
          logger.error('SettingsPage', `Router failed: ${err.message}`);
        });
      }
    });
  }

  /**
   * 切换指纹识别
   */
  async toggleBiometric(enabled: boolean) {
    if (!this.biometricSupported) {
      promptAction.showToast({
        message: '设备不支持指纹识别',
        duration: 2000
      });
      return;
    }

    try {
      await this.authService.setBiometricEnabled(enabled);
      this.biometricEnabled = enabled;
      logger.info('SettingsPage', `Biometric enabled: ${enabled}`);
      
      promptAction.showToast({
        message: enabled ? '指纹识别已开启' : '指纹识别已关闭',
        duration: 2000
      });
    } catch (err) {
      logger.error('SettingsPage', `Toggle biometric failed: ${JSON.stringify(err)}`);
      promptAction.showToast({
        message: '设置失败',
        duration: 2000
      });
    }
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Button() {
          Image($r('sys.symbol.chevron_left'))
            .width(24)
            .height(24)
            .fillColor(AppTheme.TEXT_PRIMARY)
        }
        .backgroundColor(Color.Transparent)
        .width(40)
        .height(40)
        .onClick(() => {
          router.back();
        })

        Text('设置')
          .fontSize(AppTheme.FONT_SIZE_LARGE)
          .fontColor(AppTheme.TEXT_PRIMARY)
          .fontWeight(FontWeight.Bold)
          .margin({ left: AppTheme.SPACING_SMALL })
      }
      .width('100%')
      .height(56)
      .padding({ left: AppTheme.SPACING_NORMAL, right: AppTheme.SPACING_NORMAL })
      .backgroundColor(AppTheme.CARD_BACKGROUND)

      // 设置列表
      List() {
        // 安全设置分组
        ListItemGroup({ header: this.GroupHeader('安全设置') }) {
          ListItem() {
            this.SettingItem('修改密码', '', () => {
              this.showChangePasswordDialog();
            }, false)
          }

          ListItem() {
            Row() {
              Column() {
                Text('指纹识别')
                  .fontSize(AppTheme.FONT_SIZE_MEDIUM)
                  .fontColor(AppTheme.TEXT_PRIMARY)

                if (!this.biometricSupported) {
                  Text('设备不支持')
                    .fontSize(AppTheme.FONT_SIZE_SMALL)
                    .fontColor(AppTheme.TEXT_SECONDARY)
                    .margin({ top: 4 })
                }
              }
              .alignItems(HorizontalAlign.Start)

              Blank()

              Toggle({ type: ToggleType.Switch, isOn: this.biometricEnabled })
                .enabled(this.biometricSupported)
                .selectedColor(AppTheme.PRIMARY_COLOR)
                .onChange((isOn: boolean) => {
                  this.toggleBiometric(isOn);
                })
            }
            .width('100%')
            .padding(AppTheme.SPACING_NORMAL)
            .backgroundColor(AppTheme.CARD_BACKGROUND)
          }
        }

        // 关于分组
        ListItemGroup({ header: this.GroupHeader('关于') }) {
          ListItem() {
            this.SettingItem('版本信息', '1.0.0', null, false)
          }

          ListItem() {
            this.SettingItem('关于应用', '', () => {
              promptAction.showDialog({
                title: '关于应用',
                message: '我的秘密空间\n一个安全的私密日记和相册应用',
                buttons: [{ text: '确定', color: AppTheme.PRIMARY_COLOR }]
              });
            }, false)
          }
        }
      }
      .layoutWeight(1)
      .backgroundColor(AppTheme.BACKGROUND_COLOR)
      .divider({
        strokeWidth: 1,
        color: AppTheme.DIVIDER_COLOR,
        startMargin: AppTheme.SPACING_NORMAL,
        endMargin: AppTheme.SPACING_NORMAL
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.BACKGROUND_COLOR)
  }

  @Builder
  GroupHeader(title: string) {
    Text(title)
      .fontSize(AppTheme.FONT_SIZE_SMALL)
      .fontColor(AppTheme.TEXT_SECONDARY)
      .padding({
        left: AppTheme.SPACING_NORMAL,
        right: AppTheme.SPACING_NORMAL,
        top: AppTheme.SPACING_NORMAL,
        bottom: AppTheme.SPACING_SMALL
      })
  }

  @Builder
  SettingItem(title: string, value: string, onClick: (() => void) | null, showArrow: boolean = true) {
    Row() {
      Text(title)
        .fontSize(AppTheme.FONT_SIZE_MEDIUM)
        .fontColor(AppTheme.TEXT_PRIMARY)

      Blank()

      if (value) {
        Text(value)
          .fontSize(AppTheme.FONT_SIZE_MEDIUM)
          .fontColor(AppTheme.TEXT_SECONDARY)
          .margin({ right: AppTheme.SPACING_SMALL })
      }

      if (showArrow && onClick) {
        Image($r('sys.symbol.chevron_right'))
          .width(20)
          .height(20)
          .fillColor(AppTheme.TEXT_SECONDARY)
      }
    }
    .width('100%')
    .padding(AppTheme.SPACING_NORMAL)
    .backgroundColor(AppTheme.CARD_BACKGROUND)
    .onClick(() => {
      if (onClick) {
        onClick();
      }
    })
  }
}

