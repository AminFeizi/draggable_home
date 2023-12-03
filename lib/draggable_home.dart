library draggable_home;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

class DraggableHome extends StatefulWidget {
  @override
  _DraggableHomeState createState() => _DraggableHomeState();

  /// Leading: A widget to display before the toolbar's title.
  final Widget? leading;

  /// Title: A Widget to display title in AppBar
  final Widget title;

  /// Center Title: Allows toggling of title from the center. By default title is in the center.
  final bool centerTitle;

  /// Action: A list of Widgets to display in a row after the title widget.
  final List<Widget>? actions;

  /// Always Show Leading And Action : This make Leading and Action always visible. Default value is false.
  final bool alwaysShowLeadingAndAction;

  /// Always Show Title : This make Title always visible. Default value is false.
  final bool alwaysShowTitle;

  /// Drawer: Drawers are typically used with the Scaffold.drawer property.
  final Widget? drawer;

  /// Header Expanded Height : Height of the header widget. The height is a double between 0.0 and 1.0. The default value of height is 0.35 and should be less than stretchMaxHeigh
  final double headerExpandedHeight;

  /// Header Widget: A widget to display Header above body.
  final Widget headerWidget;

  /// headerBottomBar: AppBar or toolBar like widget just above the body.

  final Widget? headerBottomBar;

  /// backgroundColor: The color of the Material widget that underlies the entire DraggableHome body.
  final Color? backgroundColor;

  /// appBarColor: The color of the scaffold app bar.
  final Color? appBarColor;

  /// curvedBodyRadius: Creates a border top left and top right radius of body, Default radius of the body is 20.0. For no radius simply set value to 0.
  final double curvedBodyRadius;

  /// body: A widget to Body
  final List<Widget> body;

  /// fullyStretchable: Allows toggling of fully expand draggability of the DraggableHome. Set this to true to allow the user to fully expand the header.
  final bool fullyStretchable;

  /// stretchTriggerOffset: The offset of overscroll required to fully expand the header.
  final double stretchTriggerOffset;

  /// expandedBody: A widget to display when fully expanded as header or expandedBody above body.
  final Widget? expandedBody;

  /// stretchMaxHeight: Height of the expandedBody widget. The height is a double between 0.0 and 0.95. The default value of height is 0.9 and should be greater than headerExpandedHeight
  final double stretchMaxHeight;

  /// floatingActionButton: An object that defines a position for the FloatingActionButton based on the Scaffold's ScaffoldPrelayoutGeometry.
  final Widget? floatingActionButton;

  /// bottomSheet: A persistent bottom sheet shows information that supplements the primary content of the app. A persistent bottom sheet remains visible even when the user interacts with other parts of the app.
  final Widget? bottomSheet;

  /// bottomNavigationBarHeight: This is requires when using custom height to adjust body height. This make no effect on bottomNavigationBar.
  final double? bottomNavigationBarHeight;

  /// bottomNavigationBar: Snack bars slide from underneath the bottom navigation bar while bottom sheets are stacked on top.
  final Widget? bottomNavigationBar;

  /// floatingActionButtonLocation: An object that defines a position for the FloatingActionButton based on the Scaffold's ScaffoldPrelayoutGeometry.
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// floatingActionButtonAnimator: Provider of animations to move the FloatingActionButton between FloatingActionButtonLocations.
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;

  final ScrollPhysics? physics;
  final PreferredSizeWidget? appBar;
  final ScrollController? scrollController;

  /// This will create DraggableHome.
  const DraggableHome(
      {Key? key,
        this.leading,
        required this.title,
        this.centerTitle = true,
        this.scrollController ,
        this.actions,
        this.alwaysShowLeadingAndAction = false,
        this.alwaysShowTitle = false,
        this.headerExpandedHeight = 0.35,
        required this.headerWidget,
        this.headerBottomBar,
        this.backgroundColor,
        this.appBarColor,
        this.curvedBodyRadius = 20,
        required this.body,
        this.drawer,
        this.fullyStretchable = false,
        this.stretchTriggerOffset = 200,
        this.expandedBody,
        this.stretchMaxHeight = 0.9,
        this.bottomSheet,
        this.appBar,
        this.bottomNavigationBarHeight = kBottomNavigationBarHeight,
        this.bottomNavigationBar,
        this.floatingActionButton,
        this.floatingActionButtonLocation,
        this.floatingActionButtonAnimator,
        this.physics})
      : assert(headerExpandedHeight > 0.0 &&
      headerExpandedHeight < stretchMaxHeight),
        assert(
        (stretchMaxHeight > headerExpandedHeight) && (stretchMaxHeight < .95),
        ),
        super(key: key);
}

class _DraggableHomeState extends State<DraggableHome> {
  final BehaviorSubject<bool> isFullyExpanded =
  BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<bool> isFullyCollapsed =
  BehaviorSubject<bool>.seeded(false);


  @override
  void dispose() {
    isFullyExpanded.close();
    isFullyCollapsed.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double appBarHeight =
        AppBar().preferredSize.height + widget.curvedBodyRadius;

    final double topPadding = MediaQuery.of(context).padding.top;

    final double expandedHeight =
        MediaQuery.of(context).size.height * widget.headerExpandedHeight;

    final double fullyExpandedHeight =
        MediaQuery.of(context).size.height * (widget.stretchMaxHeight);

    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (OverscrollIndicatorNotification notification) {
        notification.disallowIndicator();
        return false;
      },
      child: Scaffold(
        backgroundColor:
        widget.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        drawer: widget.drawer,
        appBar: widget.appBar,
        body: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.axis == Axis.vertical) {
              // isFullyCollapsed
              if ((isFullyExpanded.value) &&
                  notification.metrics.extentBefore > 100) {
                isFullyExpanded.add(false);
              }
              //isFullyCollapsed
              if (notification.metrics.extentBefore >
                  expandedHeight - AppBar().preferredSize.height - 40) {
                if (!(isFullyCollapsed.value)) isFullyCollapsed.add(true);
              } else {
                if ((isFullyCollapsed.value)) isFullyCollapsed.add(false);
              }
            }
            return false;
          },
          child: sliver(context, appBarHeight, fullyExpandedHeight,
              expandedHeight, topPadding),
        ),
        bottomSheet: widget.bottomSheet,

        bottomNavigationBar: widget.bottomNavigationBar,
        floatingActionButton: widget.floatingActionButton,
        floatingActionButtonLocation: widget.floatingActionButtonLocation,
        floatingActionButtonAnimator: widget.floatingActionButtonAnimator,
      ),
    );
  }


  Widget sliver(
      BuildContext context,
      double appBarHeight,
      double fullyExpandedHeight,
      double expandedHeight,
      double topPadding,
      ) {
    return CustomScrollView(
      physics: widget.physics,
      controller: widget.scrollController,
      slivers: [

        StreamBuilder<List<bool>>(
          stream: CombineLatestStream.list<bool>([
            isFullyCollapsed.stream,
            isFullyExpanded.stream,
          ]),
          builder:
              (BuildContext context, AsyncSnapshot<List<bool>> snapshot) {
            final List<bool> streams = (snapshot.data ?? [false, false]);
            final bool fullyCollapsed = streams[0];
            final bool fullyExpanded = streams[1];
            return SliverAppBar(
              systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarBrightness: Brightness.dark,
                  statusBarIconBrightness: Brightness.dark),
              toolbarHeight: fullyCollapsed ? 0 : kToolbarHeight,
              backgroundColor: !fullyCollapsed
                  ? widget.backgroundColor
                  : widget.appBarColor,
              leading: widget.alwaysShowLeadingAndAction
                  ? widget.leading
                  : !fullyCollapsed
                  ? const SizedBox()
                  : widget.leading,
              actions: widget.alwaysShowLeadingAndAction
                  ? widget.actions
                  : !fullyCollapsed
                  ? []
                  : widget.actions,
              elevation: 0,
              pinned: true,
              stretch: false,
              centerTitle: widget.centerTitle,
              title: widget.alwaysShowTitle
                  ? widget.title
                  : AnimatedOpacity(
                opacity: fullyCollapsed ? 1 : 0,
                duration: const Duration(milliseconds: 100),
                child: widget.title,
              ),
              collapsedHeight: fullyCollapsed ? null : appBarHeight,
              expandedHeight:
              fullyExpanded ? fullyExpandedHeight : expandedHeight,
              flexibleSpace: Stack(
                children: [
                  FlexibleSpaceBar(
                    background: Container(
                      margin: const EdgeInsets.only(bottom: 0.2),
                      child: fullyExpanded
                          ? (widget.expandedBody ?? const SizedBox())
                          : widget.headerWidget,
                    ),
                  ),
                  Positioned(
                    bottom: -1,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Container(

                            color: Colors.transparent,
                            child: roundedCorner(context)),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0 + widget.curvedBodyRadius,
                    child: AnimatedContainer(
                      padding: const EdgeInsets.only(left: 10, right: 10 ),
                      curve: Curves.easeInOutCirc,
                      duration: const Duration(milliseconds: 100),
                      height: fullyCollapsed
                          ? 0
                          : fullyExpanded
                          ? 0
                          : kToolbarHeight,
                      width: MediaQuery.of(context).size.width,
                      child: fullyCollapsed
                          ? const SizedBox()
                          : fullyExpanded
                          ? const SizedBox()
                          : widget.headerBottomBar ?? Container(),
                    ),
                  )
                ],
              ),
              stretchTriggerOffset: widget.stretchTriggerOffset,
              onStretchTrigger: widget.fullyStretchable
                  ? () async {
                if (!fullyExpanded) isFullyExpanded.add(true);
              }
                  : null,
            );
          },
        ),
        Container(

            child: sliverList(context, appBarHeight + topPadding)),
      ],
    );
  }

  Widget roundedCorner(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.only(bottom: 8),
      height: widget.curvedBodyRadius,
      width: double.infinity,
      child: CustomPaint(
        painter: RPSCustomPainter(
            backGroundShape:  widget.backgroundColor ?? const Color(0xffF4F6F8)),
      ),
    );
  }

  SliverList sliverList(BuildContext context, double topHeight) {
    final double bottomPadding =
    widget.bottomNavigationBar == null ? 0 : kBottomNavigationBarHeight;
    return SliverList(

      delegate: SliverChildListDelegate(
        [
          Stack(
            children: [
              Container(

                height:
                !isFullyCollapsed.value ? 0 :
                MediaQuery.of(context).size.height -
                    topHeight -
                    bottomPadding,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  expandedUpArrow(),
                  //Body
                  ...widget.body
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  StreamBuilder<bool> expandedUpArrow() {
    return StreamBuilder<bool>(
      stream: isFullyExpanded.stream,
      builder: (context, snapshot) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          height: (snapshot.data ?? false) ? 25 : 0,
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: Icon(
              Icons.keyboard_arrow_up_rounded,
              color: (snapshot.data ?? false) ? null : Colors.transparent,
            ),
          ),
        );
      },
    );
  }
}

class RPSCustomPainter extends CustomPainter {
  Color? smallShape;
  Color? backGroundShape;

  RPSCustomPainter({ this.backGroundShape,  this.smallShape});
  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(0, size.height);
    path_0.cubicTo(
        0,
        size.height * 0.5029450,
        size.width * 0.02066379,
        size.height * 0.1000000,
        size.width * 0.04615385,
        size.height * 0.1000000);
    path_0.lineTo(size.width * 0.3501846, size.height * 0.1000000);
    path_0.cubicTo(
        size.width * 0.3572872,
        size.height * 0.1000000,
        size.width * 0.3642923,
        size.height * 0.1319570,
        size.width * 0.3706564,
        size.height * 0.1933840);
    path_0.lineTo(size.width * 0.4108846, size.height * 0.5816150);
    path_0.cubicTo(
        size.width * 0.4172487,
        size.height * 0.6430450,
        size.width * 0.4242615,
        size.height * 0.6750000,
        size.width * 0.4313615,
        size.height * 0.6750000);
    path_0.cubicTo(
        size.width * 0.4830000,
        size.height * 0.6750000,
        size.width * 0.5161077,
        size.height * 0.6750000,
        size.width * 0.5678333,
        size.height * 0.6750000);
    path_0.cubicTo(
        size.width * 0.5747000,
        size.height * 0.6750000,
        size.width * 0.5814872,
        size.height * 0.6451250,
        size.width * 0.5876872,
        size.height * 0.5875550);
    path_0.lineTo(size.width * 0.6307718, size.height * 0.1874430);
    path_0.cubicTo(
        size.width * 0.6369692,
        size.height * 0.1298735,
        size.width * 0.6437487,
        size.height * 0.1000000,
        size.width * 0.6506154,
        size.height * 0.1000000);
    path_0.lineTo(size.width * 0.9538462, size.height * 0.1000000);
    path_0.cubicTo(size.width * 0.9793359, size.height * 0.1000000, size.width,
        size.height * 0.5029450, size.width, size.height);
    path_0.lineTo(size.width, size.height);
    path_0.lineTo(0, size.height);
    path_0.lineTo(0, size.height);
    path_0.close();

    Paint paintCustomFill = Paint();
    //   ..style = PaintingStyle.fill..color = backGroundShape ?? Colors.black;
    // Paint paint0Fill = Paint()
    //   ..style = PaintingStyle.fill
    //   ..shader =
    //   // AppColors.cardColor.createShader(
    //   //     const Rect.fromLTWH(1000, 10, 0, 300)
    //     // Rect.fromCenter(center: Offset(500, 150), width: 0, height: 300)
    //   // );
    canvas.drawPath(path_0,
        // backGroundShape ==null? paint0Fill :
        paintCustomFill);

    Path path_1 = Path();
    path_1.moveTo(size.width * 0.4435897, size.height * 0.1000000);
    path_1.lineTo(size.width * 0.5564103, size.height * 0.1000000);

    Paint paint_1_stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.01025641;
    paint_1_stroke.color = smallShape ?? Colors.white.withOpacity(0.64);
    paint_1_stroke.strokeCap = StrokeCap.round;
    canvas.drawPath(path_1, paint_1_stroke);

    Paint paint_1_fill = Paint()..style = PaintingStyle.fill;
    paint_1_fill.color = Color(0xff000000).withOpacity(1.0);
    canvas.drawPath(path_1, paint_1_fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
