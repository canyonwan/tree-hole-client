import { router } from '@kit.ArkUI';
import { DiaryService } from '../services/DiaryService';
import { DiaryModel, MoodType } from '../models/DiaryModel';
import { AppTheme } from '../theme/AppTheme';
import { MoodSelector } from '../components/MoodSelector';
import { TagManager } from '../components/TagManager';
import { UIUtils } from '../utils/UIUtils';
import { Logger } from '@ohos/common';

const logger: Logger = new Logger();

@Entry
@Component
struct DiaryEditPage {
  @State diaryId: number = 0;
  @State title: string = '';
  @State content: string = '';
  @State selectedMood: string = MoodType.HAPPY;
  @State tags: string[] = [];
  @State isLoading: boolean = false;
  @State isSaving: boolean = false;
  private diaryService: DiaryService = new DiaryService(getContext(this));

  async aboutToAppear() {
    // 获取传入的日记ID（编辑模式）
    const params = router.getParams() as Record<string, Object>;
    if (params && params['diaryId']) {
      this.diaryId = params['diaryId'] as number;
      await this.loadDiary();
    }
  }

  /**
   * 加载日记详情
   */
  async loadDiary() {
    try {
      this.isLoading = true;
      const diary = await this.diaryService.getDiaryById(this.diaryId);
      if (diary) {
        this.title = diary.title;
        this.content = diary.content;
        this.selectedMood = diary.mood;
        this.tags = this.diaryService.parseTags(diary.tags);
        logger.info('DiaryEditPage', 'Diary loaded');
      }
    } catch (err) {
      logger.error('DiaryEditPage', `Load diary failed: ${JSON.stringify(err)}`);
      UIUtils.showError('加载失败');
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 保存日记
   */
  async saveDiary() {
    if (!this.title.trim() && !this.content.trim()) {
      UIUtils.showError('请输入内容');
      return;
    }

    try {
      this.isSaving = true;

      if (this.diaryId) {
        // 更新现有日记
        await this.diaryService.updateDiary(
          this.diaryId,
          this.title.trim() || '无标题',
          this.content.trim(),
          this.selectedMood,
          this.tags
        );
        logger.info('DiaryEditPage', 'Diary updated');
      } else {
        // 创建新日记
        await this.diaryService.createDiary(
          this.title.trim() || '无标题',
          this.content.trim(),
          this.selectedMood,
          this.tags
        );
        logger.info('DiaryEditPage', 'Diary created');
      }

      UIUtils.showSuccess('保存成功');
      router.back();
    } catch (err) {
      logger.error('DiaryEditPage', `Save diary failed: ${JSON.stringify(err)}`);
      UIUtils.showError('保存失败');
    } finally {
      this.isSaving = false;
    }
  }

  /**
   * 格式化日期
   */
  formatCurrentDate(): string {
    const date = new Date();
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    const weekday = weekdays[date.getDay()];
    return `${year}年${month}月${day}日 ${weekday}`;
  }

  build() {
    Column() {
      // 顶部工具栏
      Row() {
        Button() {
          Text('←')
            .fontSize(24)
            .fontColor(AppTheme.TEXT_PRIMARY)
            .fontWeight(FontWeight.Bold)
        }
        .backgroundColor(Color.Transparent)
        .width(40)
        .height(40)
        .onClick(() => {
          router.back();
        })

        Text(this.diaryId ? '编辑日记' : '新建日记')
          .fontSize(AppTheme.FONT_SIZE_LARGE)
          .fontColor(AppTheme.TEXT_PRIMARY)
          .fontWeight(FontWeight.Bold)
          .margin({ left: AppTheme.SPACING_SMALL })

        Blank()

        Button(this.isSaving ? '保存中...' : '保存')
          .fontSize(AppTheme.FONT_SIZE_MEDIUM)
          .fontColor(AppTheme.TEXT_WHITE)
          .backgroundColor(AppTheme.PRIMARY_COLOR)
          .height(36)
          .borderRadius(AppTheme.RADIUS_MEDIUM)
          .enabled(!this.isSaving)
          .onClick(() => {
            this.saveDiary();
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: AppTheme.SPACING_NORMAL, right: AppTheme.SPACING_NORMAL })
      .backgroundColor(AppTheme.CARD_BACKGROUND)

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color(AppTheme.PRIMARY_COLOR)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            // 日期显示
            Text(this.formatCurrentDate())
              .fontSize(AppTheme.FONT_SIZE_SMALL)
              .fontColor(AppTheme.TEXT_SECONDARY)
              .alignSelf(ItemAlign.Start)

            // 标题输入
            TextInput({ placeholder: '标题（可选）', text: this.title })
              .fontSize(AppTheme.FONT_SIZE_LARGE)
              .fontWeight(FontWeight.Medium)
              .backgroundColor(Color.Transparent)
              .padding(AppTheme.SPACING_NORMAL)
              .onChange((value: string) => {
                this.title = value;
              })

            // 心情选择
            MoodSelector({ selectedMood: $selectedMood })

            Divider()
              .strokeWidth(1)
              .color(AppTheme.DIVIDER_COLOR)
              .margin({ left: AppTheme.SPACING_NORMAL, right: AppTheme.SPACING_NORMAL })

            // 标签管理
            TagManager({ tags: $tags })

            Divider()
              .strokeWidth(1)
              .color(AppTheme.DIVIDER_COLOR)
              .margin({ left: AppTheme.SPACING_NORMAL, right: AppTheme.SPACING_NORMAL })

            // 内容输入
            TextArea({ placeholder: '记录此刻的心情...', text: this.content })
              .fontSize(AppTheme.FONT_SIZE_MEDIUM)
              .backgroundColor(Color.Transparent)
              .padding(AppTheme.SPACING_NORMAL)
              .height(300)
              .onChange((value: string) => {
                this.content = value;
              })
          }
          .width('100%')
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.CARD_BACKGROUND)
  }
}

