# flutter_appears_randomly

Animation with random gradients

随机渐变出现的动画

![](https://github.com/Wing-Li/flutter_appears_randomly_animation/blob/master/img/example_video.gif)

## 使用示例

    Container(
      padding: EdgeInsets.symmetric(horizontal: 16), // 为了防止贴边不美观。（可以去掉）
      child: AppearsRandomlyWidget(
        width: screenWidth, // 整体的宽高。用于计算 item 出现的范围
        height: screenWidth,
        
        itemWidth: 56, // 每个 item 的宽高。用于计算 item 的出现
        itemHeight: 56,
        itemSizeRange: 16, // 从小变大时，最大/最小的缩放范围。（会生成随机值，此处为最大值）
        
        centerRestrictedArea: Size(iconWidth, iconWidth),  // 中心布局的范围
        centerChild: Container( // 中心布局。（可为空）
          width: iconWidth,
          height: iconWidth,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(120),
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: ClipOval(
            child: Image.asset(_getImage("header", format: "webp"), width: iconWidth, height: iconWidth),
          ),
        ),
        
        itemCount: list.length, // 总数
        itemBuilder: (context, index) { // item 布局
          var imgRes = list[index];
          return GestureDetector(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(56),
                border: Border.all(color: Colors.white, width: 0.5),
              ),
              child: ClipOval(child: Image.asset(_getImage(imgRes), width: 52, height: 52)),
            ),
            onTap: () {
              // TODO: 点击
            },
          );
        },
      ),
    ),


