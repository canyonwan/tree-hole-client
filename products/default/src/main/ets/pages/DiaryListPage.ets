import { router } from '@kit.ArkUI';
import { DiaryService } from '../services/DiaryService';
import { DiaryModel, MOOD_CONFIG } from '../models/DiaryModel';
import { AppTheme } from '../theme/AppTheme';
import { UIUtils } from '../utils/UIUtils';
import { Logger } from '@ohos/common';

const logger: Logger = new Logger();

@Component
export struct DiaryListPage {
  @State diaries: DiaryModel[] = [];
  @State isLoading: boolean = true;
  private diaryService: DiaryService = new DiaryService(getContext(this));
  private scroller: Scroller = new Scroller();

  async aboutToAppear() {
    await this.loadDiaries();
  }

  /**
   * 加载日记列表
   */
  async loadDiaries() {
    try {
      this.isLoading = true;
      this.diaries = await this.diaryService.getAllDiaries();
      logger.info('DiaryListPage', `Loaded ${this.diaries.length} diaries`);
    } catch (err) {
      logger.error('DiaryListPage', `Load diaries failed: ${JSON.stringify(err)}`);
      UIUtils.showError('加载失败');
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 删除日记
   */
  async deleteDiary(diary: DiaryModel) {
    try {
      const result = await UIUtils.showConfirmDialog({
        title: '删除日记',
        message: '确定要删除这条日记吗？',
        buttons: [
          { text: '取消', color: AppTheme.TEXT_SECONDARY },
          { text: '删除', color: AppTheme.ERROR_COLOR }
        ]
      });
      
      if (result.index === 1 && diary.id) {
        await this.diaryService.deleteDiary(diary.id);
        await this.loadDiaries();
        UIUtils.showSuccess('已删除');
      }
    } catch (err) {
      logger.error('DiaryListPage', `Delete diary failed: ${JSON.stringify(err)}`);
    }
  }

  /**
   * 获取心情信息
   */
  getMoodInfo(mood: string): string {
    const moodInfo = MOOD_CONFIG.find(m => m.type === mood);
    return moodInfo ? moodInfo.emoji : '😊';
  }

  /**
   * 格式化日期
   */
  formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    return `${month}月${day}日`;
  }

  /**
   * 格式化时间
   */
  formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    return `${hours}:${minutes}`;
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
      } else if (this.diaries.length === 0) {
        // 空状态
        Column() {
          Image($r('sys.symbol.book'))
            .width(80)
            .height(80)
            .fillColor(AppTheme.TEXT_PLACEHOLDER)
            .margin({ bottom: AppTheme.SPACING_NORMAL })

          Text('还没有日记')
            .fontSize(AppTheme.FONT_SIZE_MEDIUM)
            .fontColor(AppTheme.TEXT_SECONDARY)

          Text('点击右下角+号开始记录')
            .fontSize(AppTheme.FONT_SIZE_SMALL)
            .fontColor(AppTheme.TEXT_PLACEHOLDER)
            .margin({ top: AppTheme.SPACING_SMALL })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .opacity(0.6)
      } else {
        // 日记列表
        List({ scroller: this.scroller }) {
          ForEach(this.diaries, (diary: DiaryModel, index: number) => {
            ListItem() {
              this.DiaryCard(diary)
            }
            .margin({
              left: AppTheme.SPACING_NORMAL,
              right: AppTheme.SPACING_NORMAL,
              top: index === 0 ? AppTheme.SPACING_NORMAL : AppTheme.SPACING_SMALL,
              bottom: index === this.diaries.length - 1 ? 80 : AppTheme.SPACING_SMALL
            })
            .onClick(() => {
              router.pushUrl({
                url: 'pages/DiaryEditPage',
                params: { diaryId: diary.id }
              }).catch((err: Error) => {
                logger.error('DiaryListPage', `Router failed: ${err.message}`);
              });
            })
            .gesture(
              LongPressGesture()
                .onAction(() => {
                  this.deleteDiary(diary);
                })
            )
          }, (diary: DiaryModel) => diary.id?.toString())
        }
        .width('100%')
        .height('100%')
        .edgeEffect(EdgeEffect.Spring)
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
        router.pushUrl({
          url: 'pages/DiaryEditPage'
        }).catch((err: Error) => {
          logger.error('DiaryListPage', `Router failed: ${err.message}`);
        });
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

  @Builder
  DiaryCard(diary: DiaryModel) {
    Column() {
      // 标题和心情
      Row() {
        Text(diary.title || '无标题')
          .fontSize(AppTheme.FONT_SIZE_MEDIUM)
          .fontColor(AppTheme.TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)

        Text(this.getMoodInfo(diary.mood))
          .fontSize(24)
          .margin({ left: AppTheme.SPACING_SMALL })
      }
      .width('100%')
      .margin({ bottom: AppTheme.SPACING_SMALL })

      // 内容预览
      Text(diary.content)
        .fontSize(AppTheme.FONT_SIZE_NORMAL)
        .fontColor(AppTheme.TEXT_SECONDARY)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ bottom: AppTheme.SPACING_SMALL })

      // 标签
      if (diary.tags && diary.tags !== '[]') {
        Row() {
          ForEach(this.diaryService.parseTags(diary.tags).slice(0, 3), (tag: string) => {
            Text(`#${tag}`)
              .fontSize(AppTheme.FONT_SIZE_SMALL)
              .fontColor(AppTheme.PRIMARY_COLOR)
              .backgroundColor(AppTheme.PRIMARY_COLOR + '20')
              .padding({
                left: AppTheme.SPACING_SMALL,
                right: AppTheme.SPACING_SMALL,
                top: 4,
                bottom: 4
              })
              .borderRadius(AppTheme.RADIUS_SMALL)
              .margin({ right: AppTheme.SPACING_SMALL })
          })
        }
        .margin({ bottom: AppTheme.SPACING_SMALL })
      }

      // 日期
      Row() {
        Text(this.formatDate(diary.createTime))
          .fontSize(AppTheme.FONT_SIZE_SMALL)
          .fontColor(AppTheme.TEXT_PLACEHOLDER)

        Text(this.formatTime(diary.createTime))
          .fontSize(AppTheme.FONT_SIZE_SMALL)
          .fontColor(AppTheme.TEXT_PLACEHOLDER)
          .margin({ left: AppTheme.SPACING_SMALL })
      }
    }
    .width('100%')
    .padding(AppTheme.SPACING_NORMAL)
    .backgroundColor(AppTheme.CARD_BACKGROUND)
    .borderRadius(AppTheme.RADIUS_LARGE)
    .shadow({
      radius: 8,
      color: '#00000010',
      offsetY: 2
    })
    .transition({
      type: TransitionType.Insert,
      opacity: 0,
      translate: { y: 50 }
    })
    .animation({
      duration: 300,
      curve: Curve.EaseOut
    })
  }
}

