import { router } from '@kit.ArkUI';
import { AuthService } from '../services/AuthService';
import { AppTheme } from '../theme/AppTheme';
import { Logger } from '@ohos/common';

const logger: Logger = new Logger();

@Entry
@Component
struct LoginPage {
  @State password: string = '';
  @State confirmPassword: string = '';
  @State isSettingPassword: boolean = false;
  @State errorMessage: string = '';
  @State showError: boolean = false;
  @State shakeAnimation: boolean = false;
  private authService: AuthService = new AuthService(getContext(this));
  private maxPasswordLength: number = 6;

  async aboutToAppear() {
    const hasPassword = await this.authService.hasSetPassword();
    this.isSettingPassword = !hasPassword;
    logger.info('LoginPage', `Setting password mode: ${this.isSettingPassword}`);
  }

  /**
   * 处理数字按钮点击
   */
  handleNumberClick(num: string) {
    if (this.password.length < this.maxPasswordLength) {
      this.password += num;
      
      // 自动验证（登录模式）
      if (!this.isSettingPassword && this.password.length === this.maxPasswordLength) {
        this.verifyPassword();
      }
    }
  }

  /**
   * 删除最后一位
   */
  handleDelete() {
    if (this.password.length > 0) {
      this.password = this.password.slice(0, -1);
    }
  }

  /**
   * 验证密码
   */
  async verifyPassword() {
    try {
      const isValid = await this.authService.verifyPassword(this.password);
      if (isValid) {
        logger.info('LoginPage', 'Password verified successfully');
        router.replaceUrl({
          url: 'pages/MainPage'
        }).catch((err: Error) => {
          logger.error('LoginPage', `Router failed: ${err.message}`);
        });
      } else {
        this.showErrorMessage('密码错误，请重试');
        this.password = '';
      }
    } catch (err) {
      logger.error('LoginPage', `Verify failed: ${JSON.stringify(err)}`);
      this.showErrorMessage('验证失败');
      this.password = '';
    }
  }

  /**
   * 设置密码 - 第一次输入
   */
  handleSetPasswordFirst() {
    if (this.password.length === this.maxPasswordLength) {
      this.confirmPassword = this.password;
      this.password = '';
    }
  }

  /**
   * 设置密码 - 确认输入
   */
  async handleSetPasswordConfirm() {
    if (this.password.length === this.maxPasswordLength) {
      if (this.password === this.confirmPassword) {
        try {
          await this.authService.setPassword(this.password);
          logger.info('LoginPage', 'Password set successfully');
          router.replaceUrl({
            url: 'pages/MainPage'
          }).catch((err: Error) => {
            logger.error('LoginPage', `Router failed: ${err.message}`);
          });
        } catch (err) {
          logger.error('LoginPage', `Set password failed: ${JSON.stringify(err)}`);
          this.showErrorMessage('设置密码失败');
          this.resetPasswordSetting();
        }
      } else {
        this.showErrorMessage('两次密码不一致');
        this.resetPasswordSetting();
      }
    }
  }

  /**
   * 重置密码设置状态
   */
  resetPasswordSetting() {
    this.password = '';
    this.confirmPassword = '';
  }

  /**
   * 显示错误信息
   */
  showErrorMessage(message: string) {
    this.errorMessage = message;
    this.showError = true;
    this.shakeAnimation = true;

    setTimeout(() => {
      this.showError = false;
      this.shakeAnimation = false;
    }, 2000);
  }

  /**
   * 指纹识别
   */
  async handleBiometric() {
    try {
      const isEnabled = await this.authService.isBiometricEnabled();
      if (!isEnabled) {
        this.showErrorMessage('指纹识别未启用');
        return;
      }

      const success = await this.authService.authenticateWithBiometric();
      if (success) {
        logger.info('LoginPage', 'Biometric auth success');
        router.replaceUrl({
          url: 'pages/MainPage'
        }).catch((err: Error) => {
          logger.error('LoginPage', `Router failed: ${err.message}`);
        });
      } else {
        this.showErrorMessage('指纹识别失败');
      }
    } catch (err) {
      logger.error('LoginPage', `Biometric failed: ${JSON.stringify(err)}`);
      this.showErrorMessage('指纹识别出错');
    }
  }

  build() {
    Column() {
      // 标题区域
      Column() {
        Text('我的秘密空间')
          .fontSize(AppTheme.FONT_SIZE_TITLE)
          .fontColor(AppTheme.TEXT_PRIMARY)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: AppTheme.SPACING_SMALL })

        Text(this.isSettingPassword ? 
          (this.confirmPassword ? '再次输入密码' : '设置6位数字密码') : 
          '请输入密码')
          .fontSize(AppTheme.FONT_SIZE_NORMAL)
          .fontColor(AppTheme.TEXT_SECONDARY)
      }
      .margin({ top: 100, bottom: 60 })

      // 密码点指示器
      Row() {
        ForEach([0, 1, 2, 3, 4, 5], (index: number) => {
          Circle({ width: 16, height: 16 })
            .fill(index < this.password.length ? AppTheme.PRIMARY_COLOR : AppTheme.DIVIDER_COLOR)
            .margin({ left: index === 0 ? 0 : 20 })
            .animation({
              duration: 200,
              curve: Curve.EaseInOut
            })
        })
      }
      .margin({ bottom: 40 })
      .rotate({ angle: this.shakeAnimation ? 10 : 0 })
      .animation({
        duration: 100,
        iterations: 3,
        curve: Curve.Sharp
      })

      // 错误提示
      if (this.showError) {
        Text(this.errorMessage)
          .fontSize(AppTheme.FONT_SIZE_SMALL)
          .fontColor(AppTheme.ERROR_COLOR)
          .margin({ bottom: 20 })
          .opacity(this.showError ? 1 : 0)
          .animation({
            duration: 300,
            curve: Curve.EaseInOut
          })
      }

      // 数字键盘
      Column() {
        ForEach([['1', '2', '3'], ['4', '5', '6'], ['7', '8', '9']], (row: string[]) => {
          Row() {
            ForEach(row, (num: string) => {
              Button(num)
                .width(70)
                .height(70)
                .fontSize(AppTheme.FONT_SIZE_LARGE)
                .fontColor(AppTheme.TEXT_PRIMARY)
                .backgroundColor(AppTheme.CARD_BACKGROUND)
                .borderRadius(AppTheme.RADIUS_ROUND)
                .margin(AppTheme.SPACING_MEDIUM)
                .stateStyles({
                  pressed: {
                    .scale({ x: 0.95, y: 0.95 })
                  },
                  normal: {
                    .scale({ x: 1, y: 1 })
                  }
                })
                .onClick(() => {
                  this.handleNumberClick(num);
                })
                .animation({
                  duration: 100,
                  curve: Curve.FastOutSlowIn
                })
            })
          }
        })

        // 最后一行：指纹、0、删除
        Row() {
          // 指纹按钮（仅登录模式显示）
          if (!this.isSettingPassword) {
            Button() {
              Text('👆')
                .fontSize(30)
                .fontColor(AppTheme.PRIMARY_COLOR)
            }
            .width(70)
            .height(70)
            .backgroundColor(AppTheme.CARD_BACKGROUND)
            .borderRadius(AppTheme.RADIUS_ROUND)
            .margin(AppTheme.SPACING_MEDIUM)
            .onClick(() => {
              this.handleBiometric();
            })
          } else {
            Blank()
              .width(70)
              .margin(AppTheme.SPACING_MEDIUM)
          }

          // 数字0
          Button('0')
            .width(70)
            .height(70)
            .fontSize(AppTheme.FONT_SIZE_LARGE)
            .fontColor(AppTheme.TEXT_PRIMARY)
            .backgroundColor(AppTheme.CARD_BACKGROUND)
            .borderRadius(AppTheme.RADIUS_ROUND)
            .margin(AppTheme.SPACING_MEDIUM)
            .onClick(() => {
              this.handleNumberClick('0');
            })

          // 删除按钮
          Button() {
            Image($r('sys.symbol.delete_left'))
              .width(30)
              .height(30)
              .fillColor(AppTheme.TEXT_SECONDARY)
          }
          .width(70)
          .height(70)
          .backgroundColor(AppTheme.CARD_BACKGROUND)
          .borderRadius(AppTheme.RADIUS_ROUND)
          .margin(AppTheme.SPACING_MEDIUM)
          .onClick(() => {
            this.handleDelete();
          })
        }
      }
      .margin({ top: 40 })

      // 确认按钮（设置密码模式）
      if (this.isSettingPassword && this.password.length === this.maxPasswordLength) {
        Button(this.confirmPassword ? '确认设置' : '继续')
          .width(200)
          .height(48)
          .fontSize(AppTheme.FONT_SIZE_MEDIUM)
          .fontColor(AppTheme.TEXT_WHITE)
          .backgroundColor(AppTheme.PRIMARY_COLOR)
          .borderRadius(AppTheme.RADIUS_LARGE)
          .margin({ top: 40 })
          .onClick(() => {
            if (this.confirmPassword) {
              this.handleSetPasswordConfirm();
            } else {
              this.handleSetPasswordFirst();
            }
          })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.BACKGROUND_COLOR)
  }
}

