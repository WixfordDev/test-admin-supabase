import 'package:deenhub/config/themes/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deenhub/config/themes/decoration_styles.dart';
import 'package:deenhub/core/utils/view_utils.dart';

class AppBarScaffold extends StatelessWidget {
  final String? pageTitle;
  final Widget? searchBar;
  final bool? centerTitle;
  final EdgeInsetsDirectional padding;
  final Widget? child;
  final List<Widget>? children;
  final List<Widget>? appBarActions;
  final bool useScrollView;
  final bool showScrollbar;
  final bool automaticallyImplyLeading;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  const AppBarScaffold({
    super.key,
    this.pageTitle,
    this.searchBar,
    this.centerTitle = false,
    this.padding = EdgeInsetsDirectional.zero,
    this.child,
    this.children,
    this.appBarActions,
    this.useScrollView = false,
    this.showScrollbar = false,
    this.automaticallyImplyLeading = true,
    this.floatingActionButtonLocation,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    // final appBarColor = context.tertiaryColor;
    final appBarColor = context.primaryColor;

    return Scaffold(
      // Enable proper system UI insets handling for edge-to-edge display
      resizeToAvoidBottomInset: true,
      extendBody: true,
      // Don't extend body behind app bar to prevent clashing
      extendBodyBehindAppBar: false,
      appBar: PreferredSize(
        // Add extra height to accommodate for status bar
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          systemOverlayStyle: DecorationStyles.appBarSystemUiOverlayStyle(
              appBarColor: appBarColor),
          backgroundColor: appBarColor,
          foregroundColor: context.onPrimaryColor,
          title: searchBar ?? Text(pageTitle!),
          titleSpacing: 0,
          actionsPadding: p0,
          centerTitle: centerTitle,
          actions: appBarActions,
          scrolledUnderElevation: 0.0,
          automaticallyImplyLeading: automaticallyImplyLeading,
        ),
      ),
      body: SafeArea(
        // Only handle bottom padding, let AppBar handle top padding
        top: false,
        child: useScrollView
            ? showScrollbar
                ? CupertinoScrollbar(child: _buildScrollView())
                : _buildScrollView()
            : _buildViewsContainer(),
      ),
      bottomNavigationBar: bottomNavigationBar != null
          ? SafeArea(top: false, child: bottomNavigationBar!)
          : null,
      floatingActionButtonLocation: floatingActionButtonLocation,
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildScrollView() =>
      SingleChildScrollView(child: _buildViewsContainer());

  Widget _buildViewsContainer() => (child ??
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children!,
          ))
      .withPadding(padding);
}
