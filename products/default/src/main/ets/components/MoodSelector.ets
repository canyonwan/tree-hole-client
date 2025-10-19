import { MOOD_CONFIG, MoodInfo, MoodType } from '../models/DiaryModel';
import { AppTheme } from '../theme/AppTheme';

@Component
export struct MoodSelector {
  @Link selectedMood: string;

  build() {
    Column() {
      Text('今天的心情')
        .fontSize(AppTheme.FONT_SIZE_SMALL)
        .fontColor(AppTheme.TEXT_SECONDARY)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: AppTheme.SPACING_SMALL })

      Row() {
        ForEach(MOOD_CONFIG, (mood: MoodInfo) => {
          Column() {
            Text(mood.emoji)
              .fontSize(32)
              .padding(AppTheme.SPACING_SMALL)

            Text(mood.label)
              .fontSize(AppTheme.FONT_SIZE_SMALL)
              .fontColor(this.selectedMood === mood.type ? AppTheme.PRIMARY_COLOR : AppTheme.TEXT_SECONDARY)
              .margin({ top: 4 })
          }
          .width(60)
          .height(80)
          .backgroundColor(this.selectedMood === mood.type ? 
            AppTheme.PRIMARY_COLOR + '20' : 
            AppTheme.BACKGROUND_COLOR)
          .borderRadius(AppTheme.RADIUS_MEDIUM)
          .borderWidth(2)
          .borderColor(this.selectedMood === mood.type ? 
            AppTheme.PRIMARY_COLOR : 
            Color.Transparent)
          .justifyContent(FlexAlign.Center)
          .margin({ right: AppTheme.SPACING_SMALL })
          .onClick(() => {
            this.selectedMood = mood.type;
          })
          .scale({
            x: this.selectedMood === mood.type ? 1.05 : 1,
            y: this.selectedMood === mood.type ? 1.05 : 1
          })
          .animation({
            duration: 200,
            curve: Curve.EaseInOut
          })
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding(AppTheme.SPACING_NORMAL)
  }
}

