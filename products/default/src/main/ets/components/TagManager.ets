import { AppTheme } from '../theme/AppTheme';

@Component
export struct TagManager {
  @Link tags: string[];
  @State inputTag: string = '';
  @State showInput: boolean = false;

  /**
   * 添加标签
   */
  addTag() {
    if (this.inputTag.trim() && !this.tags.includes(this.inputTag.trim())) {
      this.tags.push(this.inputTag.trim());
      this.inputTag = '';
      this.showInput = false;
    }
  }

  /**
   * 删除标签
   */
  removeTag(index: number) {
    this.tags.splice(index, 1);
  }

  build() {
    Column() {
      Text('标签')
        .fontSize(AppTheme.FONT_SIZE_SMALL)
        .fontColor(AppTheme.TEXT_SECONDARY)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: AppTheme.SPACING_SMALL })

      Flex({ wrap: FlexWrap.Wrap }) {
        // 现有标签
        ForEach(this.tags, (tag: string, index: number) => {
          Row() {
            Text(`#${tag}`)
              .fontSize(AppTheme.FONT_SIZE_SMALL)
              .fontColor(AppTheme.PRIMARY_COLOR)

            Text('×')
              .fontSize(18)
              .fontColor(AppTheme.PRIMARY_COLOR)
              .fontWeight(FontWeight.Bold)
              .margin({ left: 4 })
              .onClick(() => {
                this.removeTag(index);
              })
          }
          .padding({
            left: AppTheme.SPACING_SMALL,
            right: AppTheme.SPACING_SMALL,
            top: 6,
            bottom: 6
          })
          .backgroundColor(AppTheme.PRIMARY_COLOR + '20')
          .borderRadius(AppTheme.RADIUS_SMALL)
          .margin({ right: AppTheme.SPACING_SMALL, bottom: AppTheme.SPACING_SMALL })
          .opacity(1)
          .animation({
            duration: 300,
            curve: Curve.EaseInOut
          })
        }, (tag: string, index: number) => `${tag}_${index}`)

        // 添加标签按钮/输入框
        if (this.showInput) {
          Row() {
            TextInput({ placeholder: '标签名称', text: this.inputTag })
              .width(100)
              .height(32)
              .fontSize(AppTheme.FONT_SIZE_SMALL)
              .padding({ left: AppTheme.SPACING_SMALL, right: AppTheme.SPACING_SMALL })
              .backgroundColor(AppTheme.BACKGROUND_COLOR)
              .onChange((value: string) => {
                this.inputTag = value;
              })
              .onSubmit(() => {
                this.addTag();
              })

            Button('确定')
              .fontSize(AppTheme.FONT_SIZE_SMALL)
              .height(32)
              .backgroundColor(AppTheme.PRIMARY_COLOR)
              .margin({ left: 4 })
              .onClick(() => {
                this.addTag();
              })

            Button('取消')
              .fontSize(AppTheme.FONT_SIZE_SMALL)
              .height(32)
              .backgroundColor(AppTheme.TEXT_SECONDARY)
              .margin({ left: 4 })
              .onClick(() => {
                this.showInput = false;
                this.inputTag = '';
              })
          }
          .margin({ bottom: AppTheme.SPACING_SMALL })
        } else {
          Button() {
            Row() {
              Text('+')
                .fontSize(16)
                .fontColor(AppTheme.PRIMARY_COLOR)
                .fontWeight(FontWeight.Bold)

              Text('添加标签')
                .fontSize(AppTheme.FONT_SIZE_SMALL)
                .fontColor(AppTheme.PRIMARY_COLOR)
                .margin({ left: 4 })
            }
          }
          .height(32)
          .padding({ left: AppTheme.SPACING_SMALL, right: AppTheme.SPACING_SMALL })
          .backgroundColor(AppTheme.PRIMARY_COLOR + '20')
          .borderRadius(AppTheme.RADIUS_SMALL)
          .onClick(() => {
            this.showInput = true;
          })
        }
      }
      .width('100%')
    }
    .width('100%')
    .padding(AppTheme.SPACING_NORMAL)
  }
}

