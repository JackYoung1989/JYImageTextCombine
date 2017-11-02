# JYImageTextCombine
图文混排 图文并茂 NSAttributedString转html  html转NSAttributedString 

http://player.youku.com/embed/XMzEyOTE4Mjk0MA==

使用方法：

    JYImageTextCombineViewController就是一个textView的控制器，将该类拖入项目中
    1.修改服务器上传和下载图片的网络接口。
    2.设置项目需要的文本字体大小等属性。
    
    /*
    * oldHtmlString:包含两种标签<div>和<img>两种标签，文本用<div>，图片用<img src="http://...." style=width:99%/>表示
    * 每个标签中间没有空格
    * returnBlock:是返回的字符串格式同上
    */
    
    和后台约定的数据格式：
    <div>JackYoung's</div><img src="https://ss0.bdstatic.com/5aV1bjqh_Q23odCf/static/superman/img/logo/bd_logo1_31bdc765.png" style="width:99%"/><div>如果帮到你，给一个🌟🌟🌟🌟🌟哦</div><img src="https://ss0.bdstatic.com/5aV1bjqh_Q23odCf/static/superman/img/logo/bd_logo1_31bdc765.png" style="width:99%"/>
    


