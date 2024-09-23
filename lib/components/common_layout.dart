import 'package:music_dabang/common/colors.dart';
import 'package:flutter/material.dart';

const screenHorizontalPadding = 20.0;

class CommonLayout extends StatelessWidget {
  // appBar는 모든 appBar 속성에 대해 우선 순위를 가짐
  final AppBar? appBar;
  final bool hideAppBar;
  // 뒤로 가기 버튼 구현 여부
  final bool automaticallyImplyLeading;
  // appBar leading widget
  final Widget? leading;
  final String? title;
  final TextStyle? titleStyle;
  // titleWidget은 title보다 높은 우선순위를 가짐
  final Widget? titleWidget;
  final double? titleSpacing;
  final bool? centerTitle;
  final List<Widget>? actions;
  // floating action button
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  // scaffold option
  final bool? resizeToAvoidBottomInset;
  final EdgeInsets? padding;
  // child
  final Widget child;
  final Color backgroundColor;
  final Widget? bottomNavigationBar;

  const CommonLayout({
    this.appBar,
    this.hideAppBar = false,
    this.automaticallyImplyLeading = true,
    this.leading,
    this.title,
    this.titleStyle,
    this.titleWidget,
    this.titleSpacing,
    this.centerTitle = true,
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.resizeToAvoidBottomInset,
    this.padding =
        const EdgeInsets.symmetric(horizontal: screenHorizontalPadding),
    required this.child,
    this.backgroundColor = Colors.white,
    this.bottomNavigationBar,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // appBarTitle 렌더링
    Widget? appBarTitle;
    if (titleWidget != null) {
      appBarTitle = titleWidget;
    } else if (title != null) {
      appBarTitle = Text(
        title!,
        style: titleStyle ??
            const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w700,
              color: ColorTable.enabledColor,
            ),
      );
    }
    // appBar 렌더링
    PreferredSizeWidget? _appBar;
    if (!hideAppBar) {
      _appBar = appBar ??
          AppBar(
            leading: automaticallyImplyLeading
                ? leading ??
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      iconSize: 24.0,
                      splashRadius: 24.0,
                      icon: const Icon(Icons.arrow_back),
                    )
                : leading,
            automaticallyImplyLeading: automaticallyImplyLeading,
            title: appBarTitle,
            titleSpacing: titleSpacing,
            centerTitle: centerTitle,
            actions: actions,
          );
    }

    return Scaffold(
      appBar: _appBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: backgroundColor,
      body: padding != null
          ? Padding(
              padding: padding!,
              child: child,
            )
          : child,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
