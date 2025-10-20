import { router } from '@kit.ArkUI';
import { PhotoService } from '../services/PhotoService';
import { PhotoModel } from '../models/PhotoModel';
import { AppTheme } from '../theme/AppTheme';
import { UIUtils } from '../utils/UIUtils';
import { Logger } from '@ohos/common';

const logger: Logger = new Logger();

@Component
export struct PhotoGridPage {
  @State photos: PhotoModel[] = [];
  @State isLoading: boolean = true;
  private photoService: PhotoService = new PhotoService(getContext(this));

  async aboutToAppear() {
    await this.loadPhotos();
  }

  /**
   * 加载照片列表
   */
  async loadPhotos() {
    try {
      this.isLoading = true;
      this.photos = await this.photoService.getAllPhotos();
      logger.info('PhotoGridPage', `Loaded ${this.photos.length} photos`);
    } catch (err) {
      logger.error('PhotoGridPage', `Load photos failed: ${JSON.stringify(err)}`);
      UIUtils.showError('加载失败');
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 选择并添加照片
   */
  async addPhotos() {
    try {
      const uris = await this.photoService.selectPhotos();
      
      if (uris && uris.length > 0) {
        UIUtils.showLoading('正在保存...');
        
        for (const uri of uris) {
          await this.photoService.savePhoto(uri, '');
        }
        
        await this.loadPhotos();
        UIUtils.showSuccess('添加成功');
      }
    } catch (err) {
      logger.error('PhotoGridPage', `Add photos failed: ${JSON.stringify(err)}`);
      UIUtils.showError('添加失败');
    }
  }

  /**
   * 删除照片
   */
  async deletePhoto(photo: PhotoModel) {
    try {
      const result = await UIUtils.showConfirmDialog({
        title: '删除照片',
        message: '确定要删除这张照片吗？',
        buttons: [
          { text: '取消', color: AppTheme.TEXT_SECONDARY },
          { text: '删除', color: AppTheme.ERROR_COLOR }
        ]
      });
      
      if (result.index === 1 && photo.id) {
        await this.photoService.deletePhoto(photo.id, photo.filePath);
        await this.loadPhotos();
        UIUtils.showSuccess('已删除');
      }
    } catch (err) {
      logger.error('PhotoGridPage', `Delete photo failed: ${JSON.stringify(err)}`);
    }
  }

  build() {
    Stack() {
      if (this.isLoading) {
        // 加载中
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color(AppTheme.PRIMARY_COLOR)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.photos.length === 0) {
        // 空状态
        Column() {
          Text('📷')
            .fontSize(80)
            .fontColor(AppTheme.TEXT_PLACEHOLDER)
            .margin({ bottom: AppTheme.SPACING_NORMAL })

          Text('还没有照片')
            .fontSize(AppTheme.FONT_SIZE_MEDIUM)
            .fontColor(AppTheme.TEXT_SECONDARY)

          Text('点击右下角+号添加照片')
            .fontSize(AppTheme.FONT_SIZE_SMALL)
            .fontColor(AppTheme.TEXT_PLACEHOLDER)
            .margin({ top: AppTheme.SPACING_SMALL })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .opacity(0.6)
      } else {
        // 照片网格
        Grid() {
          ForEach(this.photos, (photo: PhotoModel, index: number) => {
            GridItem() {
              Stack() {
                Image(photo.filePath)
                  .width('100%')
                  .height('100%')
                  .objectFit(ImageFit.Cover)
                  .borderRadius(AppTheme.RADIUS_MEDIUM)
              }
              .width('100%')
              .aspectRatio(1)
              .shadow({
                radius: 4,
                color: '#00000015',
                offsetY: 2
              })
              .transition({
                type: TransitionType.Insert,
                opacity: 0,
                scale: { x: 0.8, y: 0.8 }
              })
              .animation({
                duration: 300,
                curve: Curve.EaseInOut
              })
            }
            .onClick(() => {
              router.pushUrl({
                url: 'pages/PhotoDetailPage',
                params: {
                  photoId: photo.id,
                  currentIndex: index
                }
              }).catch((err: Error) => {
                UIUtils.showError('打开失败');
              });
            })
            .gesture(
              LongPressGesture()
                .onAction(() => {
                  this.deletePhoto(photo);
                })
            )
          }, (photo: PhotoModel) => photo.id?.toString())
        }
        .columnsTemplate('1fr 1fr 1fr')
        .columnsGap(AppTheme.SPACING_SMALL)
        .rowsGap(AppTheme.SPACING_SMALL)
        .padding({
          left: AppTheme.SPACING_NORMAL,
          right: AppTheme.SPACING_NORMAL,
          top: AppTheme.SPACING_NORMAL,
          bottom: 80
        })
        .width('100%')
        .height('100%')
      }

      // 添加按钮
      Button() {
        Image($r('sys.symbol.plus'))
          .width(28)
          .height(28)
          .fillColor(AppTheme.TEXT_WHITE)
      }
      .width(60)
      .height(60)
      .backgroundColor(AppTheme.PRIMARY_COLOR)
      .borderRadius(AppTheme.RADIUS_ROUND)
      .position({ x: '85%', y: '85%' })
      .translate({ x: '-50%', y: '-50%' })
      .shadow({
        radius: 12,
        color: AppTheme.PRIMARY_COLOR,
        offsetY: 4
      })
      .onClick(() => {
        this.addPhotos();
      })
      .scale({ x: 1, y: 1 })
      .animation({
        duration: 200,
        curve: Curve.FastOutSlowIn
      })
    }
    .width('100%')
    .height('100%')
  }
}

