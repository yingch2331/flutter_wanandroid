import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wanandroid/common/component_index.dart';
import 'package:flutter_wanandroid/ui/pages/page_index.dart';

class _Page {
  final String labelId;

  _Page(this.labelId);
}

final List<_Page> _allPages = <_Page>[
  new _Page(
    Ids.titleHome,
  ),
  new _Page(Ids.titleRepos),
  new _Page(Ids.titleEvents),
  new _Page(Ids.titleSystem),
];

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _MainPage();
  }
}

class _MainPage extends State<MainPage> {
  PageController _pageController;

  int _page = 0;

  /*
   * 存放三个页面，跟fragmentList一样
   */
  var _pageList;

  EventBus eventBus;

  void initData(BuildContext context) {
    /*
     * 三个子界面
     */
    _pageList = [
      buildTabView(context, _allPages[0]),
      buildTabView(context, _allPages[1]),
      buildTabView(context, _allPages[2]),
      buildTabView(context, _allPages[3])
    ];
  }

  Widget buildTabView(BuildContext context, _Page page) {
    String labelId = page.labelId;
    switch (labelId) {
      case Ids.titleHome:
        return HomePage(labelId: labelId);
        break;
      case Ids.titleRepos:
        return ReposPage(labelId: labelId);
        break;
      case Ids.titleEvents:
        return EventsPage(labelId: labelId);
        break;
      case Ids.titleSystem:
        return SystemPage(labelId: labelId);
        break;
      default:
        return Container();
        break;
    }
  }

  Future<bool> _onBackPressed() {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('确定退出程序吗?'),
              actions: <Widget>[
                FlatButton(
                  child: Text('暂不'),
                  onPressed: () => Navigator.pop(context, false),
                ),
                FlatButton(
                  child: Text('确定'),
                  onPressed: () => Navigator.pop(context, true),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    LogUtil.e("MainPagess build......");
    // 初始化数据
    initData(context);
    return WillPopScope(
        child: Scaffold(
            body: new PageView.custom(
              childrenDelegate: new SliverChildBuilderDelegate(
                (context, index) {
                  return _pageList[index];
                },
                childCount: _allPages.length,
              ),
              controller: _pageController,
              onPageChanged: (int index) {
                eventBus.fire(new PageChangeEvent(index));
              },
            ), // _pageList[_tabIndex]
            bottomNavigationBar: BottomAppBar(
              color: Colors.lightBlue,
              shape: CircularNotchedRectangle(),
              child: CustomBottomTabBar(_pageController, eventBus),
            )),
        onWillPop: _onBackPressed);
  }

  @override
  void initState() {
    super.initState();
    _pageController = new PageController(initialPage: this._page);
    eventBus = new EventBus();
  }
}


class CustomBottomTabBar extends StatefulWidget {
  final PageController pageController;
  final EventBus eventBus;

  const CustomBottomTabBar(this.pageController, this.eventBus);

  @override
  State<StatefulWidget> createState() => new _CustomBottomTabBar();
}

class _CustomBottomTabBar extends State<CustomBottomTabBar> {
  int _index = 0;

  /*
   * 根据image路径获取图片
   */
  Image getTabImage(path) {
    return new Image.asset(path, width: 24.0, height: 24.0);
  }

  var _tabImages;

  /*
   * 根据选择获得对应的normal或是press的icon
   */
  Image getTabIcon(int curIndex) {
    if (curIndex == _index) {
      return _tabImages[curIndex][1];
    }
    return _tabImages[curIndex][0];
  }

  void initData() {
    /*
     * 初始化选中和未选中的icon
     */
    _tabImages = [
      [
        getTabImage(Utils.getImgPath('ic_nav_discover_normal')),
        getTabImage(Utils.getImgPath('ic_nav_discover_actived'))
      ],
      [
        getTabImage(Utils.getImgPath('ic_nav_tweet_normal')),
        getTabImage(Utils.getImgPath('ic_nav_tweet_actived'))
      ],
      [
        getTabImage(Utils.getImgPath('ic_nav_news_normal')),
        getTabImage(Utils.getImgPath('ic_nav_news_actived'))
      ],
      [
        getTabImage(Utils.getImgPath('ic_nav_my_normal')),
        getTabImage(Utils.getImgPath('ic_nav_my_actived'))
      ]
    ];
  }

  /*
   * 获取bottomTab的颜色和文字
   */
  Text getTabTitle(int curIndex) {
    if (curIndex == _index) {
      return new Text(IntlUtil.getString(context, _allPages[curIndex].labelId),
          style: new TextStyle(fontSize: 14.0, color: const Color(0xff1296db)));
    } else {
      return new Text(IntlUtil.getString(context, _allPages[curIndex].labelId),
          style: new TextStyle(fontSize: 14.0, color: const Color(0xff515151)));
    }
  }

  @override
  Widget build(BuildContext context) {
    initData();
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        buildIcon(0),
        buildIcon(1),
        buildIcon(2),
        buildIcon(3),
      ],
    );
  }

  Widget buildIcon(int index, {int flex = 1, Color color}) {
    void onTop() {
      print('ontop-->$index');
      widget.pageController.jumpToPage(index);
    }

    return Expanded(
      child: InkWell(
        onTap: onTop,
        child: new Container(
          color: color,
          padding: EdgeInsets.only(bottom: 8.0, top: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              getTabIcon(index),
              new Container(
                margin: const EdgeInsets.only(top: 8.0),
                child: getTabTitle(index),
              )
            ],
          ),
        ),
      ),
      flex: flex,
    );
  }

  @override
  void initState() {
    super.initState();
    _initListener();
  }

  void onPressed(int index) {
    setState(() {
      _index = index;
    });
  }

  void _initListener() {
    widget.eventBus
        .on<PageChangeEvent>()
        .listen((PageChangeEvent data) => onPageChange(data.page));
  }

  void onPageChange(int index) {
    print('nav bar selected index：$index');
    setState(() {
      _index = index;
    });
  }
}
