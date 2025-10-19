import { router } from '@kit.ArkUI';
import { PhotoService } from '../services/PhotoService';
import { PhotoModel } from '../models/PhotoModel';
import { AppTheme } from '../theme/AppTheme';
import { promptAction } from '@kit.ArkUI';
import { Logger } from '../../../common/src/main/ets/utils/Logger';

const logger = new Logger();

@Entry
@Component
struct PhotoDetailPage {
  @State photos: PhotoModel[] = [];
  @State currentIndex: number = 0;
  @State showToolbar: boolean = true;
  @State scale: number = 1;
  private photoService: PhotoService = new PhotoService(getContext(this));
  private panOption: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.Horizontal });

  async aboutToAppear() {
    const params = router.getParams() as Record<string, Object>;
    if (params && params['currentIndex'] !== undefined) {
      this.currentIndex = params['currentIndex'] as number;
    }
    await this.loadPhotos();
  }

  /**
   * 加载照片列表
   */
  async loadPhotos() {
    try {
      this.photos = await this.photoService.getAllPhotos();
      logger.info('PhotoDetailPage', `Loaded ${this.photos.length} photos`);
    } catch (err) {
      logger.error('PhotoDetailPage', `Load photos failed: ${JSON.stringify(err)}`);
    }
  }

  /**
   * 删除当前照片
   */
  async deleteCurrentPhoto() {
    if (this.photos.length === 0 || this.currentIndex >= this.photos.length) {
      return;
    }

    const photo = this.photos[this.currentIndex];
    
    try {
      await promptAction.showDialog({
        title: '删除照片',
        message: '确定要删除这张照片吗？',
        buttons: [
          { text: '取消', color: AppTheme.TEXT_SECONDARY },
          { text: '删除', color: AppTheme.ERROR_COLOR }
        ]
      }).then(async (result) => {
        if (result.index === 1 && photo.id) {
          await this.photoService.deletePhoto(photo.id, photo.filePath);
          
          // 如果删除后没有照片了，返回上一页
          if (this.photos.length === 1) {
            router.back();
          } else {
            // 重新加载照片列表
            await this.loadPhotos();
            // 调整当前索引
            if (this.currentIndex >= this.photos.length) {
              this.currentIndex = this.photos.length - 1;
            }
          }
          
          promptAction.showToast({ message: '已删除', duration: 2000 });
        }
      });
    } catch (err) {
      logger.error('PhotoDetailPage', `Delete photo failed: ${JSON.stringify(err)}`);
    }
  }

  /**
   * 格式化日期
   */
  formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    return `${year}年${month}月${day}日 ${hours}:${minutes}`;
  }

  build() {
    Stack() {
      // 照片轮播
      if (this.photos.length > 0) {
        Swiper() {
          ForEach(this.photos, (photo: PhotoModel) => {
            Stack() {
              Image(photo.filePath)
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Contain)
                .scale({ x: this.scale, y: this.scale })
                .gesture(
                  PinchGesture()
                    .onActionUpdate((event: GestureEvent) => {
                      this.scale = event.scale;
                    })
                    .onActionEnd(() => {
                      if (this.scale < 1) {
                        this.scale = 1;
                      }
                      if (this.scale > 3) {
                        this.scale = 3;
                      }
                    })
                )
                .onClick(() => {
                  this.showToolbar = !this.showToolbar;
                })
            }
            .width('100%')
            .height('100%')
          }, (photo: PhotoModel) => photo.id?.toString())
        }
        .index(this.currentIndex)
        .indicator(false)
        .loop(false)
        .onChange((index: number) => {
          this.currentIndex = index;
          this.scale = 1;
        })
      }

      // 顶部工具栏
      if (this.showToolbar) {
        Row() {
          Button() {
            Image($r('sys.symbol.chevron_left'))
              .width(24)
              .height(24)
              .fillColor(AppTheme.TEXT_WHITE)
          }
          .backgroundColor('rgba(0, 0, 0, 0.5)')
          .width(40)
          .height(40)
          .borderRadius(AppTheme.RADIUS_ROUND)
          .onClick(() => {
            router.back();
          })

          Blank()

          Text(`${this.currentIndex + 1} / ${this.photos.length}`)
            .fontSize(AppTheme.FONT_SIZE_MEDIUM)
            .fontColor(AppTheme.TEXT_WHITE)
            .backgroundColor('rgba(0, 0, 0, 0.5)')
            .padding({
              left: AppTheme.SPACING_NORMAL,
              right: AppTheme.SPACING_NORMAL,
              top: AppTheme.SPACING_SMALL,
              bottom: AppTheme.SPACING_SMALL
            })
            .borderRadius(AppTheme.RADIUS_MEDIUM)

          Blank()

          Button() {
            Image($r('sys.symbol.trash'))
              .width(24)
              .height(24)
              .fillColor(AppTheme.TEXT_WHITE)
          }
          .backgroundColor('rgba(239, 68, 68, 0.8)')
          .width(40)
          .height(40)
          .borderRadius(AppTheme.RADIUS_ROUND)
          .onClick(() => {
            this.deleteCurrentPhoto();
          })
        }
        .width('100%')
        .padding(AppTheme.SPACING_NORMAL)
        .position({ x: 0, y: 0 })
        .opacity(this.showToolbar ? 1 : 0)
        .animation({
          duration: 300,
          curve: Curve.EaseInOut
        })
      }

      // 底部信息栏
      if (this.showToolbar && this.photos.length > 0 && this.currentIndex < this.photos.length) {
        Column() {
          if (this.photos[this.currentIndex].description) {
            Text(this.photos[this.currentIndex].description)
              .fontSize(AppTheme.FONT_SIZE_MEDIUM)
              .fontColor(AppTheme.TEXT_WHITE)
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ bottom: AppTheme.SPACING_SMALL })
          }

          Text(this.formatDate(this.photos[this.currentIndex].createTime))
            .fontSize(AppTheme.FONT_SIZE_SMALL)
            .fontColor(AppTheme.TEXT_WHITE)
            .opacity(0.8)
        }
        .width('100%')
        .padding(AppTheme.SPACING_NORMAL)
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .position({ x: 0, y: '100%' })
        .translate({ x: 0, y: '-100%' })
        .opacity(this.showToolbar ? 1 : 0)
        .animation({
          duration: 300,
          curve: Curve.EaseInOut
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
  }
}

