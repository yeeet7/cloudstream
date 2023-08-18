
// ignore_for_file: must_be_immutable


import 'package:cloudstream/view/secondary/video.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:movie_provider/movie_provider.dart';
import 'package:shimmer/shimmer.dart';

extension Index<E, T> on Iterable<E> {
  Iterable<T> mapIndexed(T Function(E e, int index) function) {
    List<T> list = [];
    for (var i = 0; i < length; i++) {
      list.add(function.call(toList()[i], i));
    }
    return list;
  }
}

class PictureIcon extends StatelessWidget {

  PictureIcon(this.path, {this.padding, this.size = 20, this.color, super.key});
  final String path;
  final double size;
  Color? color;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    Color? iconColor = color ?? IconTheme.of(context).color;
    return Container(
      width: size,
      height: size,
      padding: padding,
      child: Image.asset(path, color: iconColor, width: size, height: size),
    );
  }
}

class BottomNavBar extends StatefulWidget {
  BottomNavBar({required this.items, required this.selected, super.key}):assert(items.length >= 2),assert(selected >= 0 && selected < items.length);
  final List<BottomNavBarItem> items;
  int selected;

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: (widget.items.mapIndexed((e, index) => widget.selected == index ? (e..selected = true) : (e..selected = false)).toList()).cast<Widget>(),
      ),
    );
  }
}

class BottomNavBarItem extends StatelessWidget {
  
  BottomNavBarItem(this.icon, {required this.onTap, this.selected = false, this.color, this.title = '', this.onLongTap, super.key});
  final String? title;
  final PictureIcon icon;
  Color? color;
  void Function() onTap;
  void Function()? onLongTap;
  bool selected;

  @override
  Widget build(BuildContext context) {
    Color iconColor = selected ? (color ?? Theme.of(context).primaryColor) : Theme.of(context).colorScheme.secondary;
    return SizedBox(
      height: 60,
      width: 60,
      child: Material(
        borderRadius: BorderRadius.circular(30),
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onTap,
          onLongPress: onLongTap == null ? null : () {
            onTap.call();
            onLongTap?.call();
          },
          highlightColor: Theme.of(context).primaryColor.withAlpha(70),
          child: Container(
            width: 60,
            height: 32.5,
            margin: const EdgeInsets.symmetric(vertical: 15),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
            decoration: BoxDecoration(
              color: selected ? iconColor.withAlpha(40) : iconColor.withAlpha(0),
              borderRadius: BorderRadius.circular(16)
            ),
            child: icon..color = iconColor.withAlpha(255),
          ),
        ),
      ),
    );
  }
}

class Button extends StatelessWidget {
  const Button({required this.text, this.textColor, this.buttonColor, this.borderRadius = BorderRadius.zero, this.icon, this.iconIsLeading = false, this.centerTitle = false, this.onTap, super.key});
  final String text;
  final Color? textColor;
  final Color? buttonColor;
  final BorderRadius borderRadius;
  final Widget? icon;
  final bool iconIsLeading;
  final bool centerTitle;
  final void Function()? onTap;
 
  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: borderRadius,
      color: buttonColor ?? Colors.transparent,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
          ),
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: centerTitle ? MainAxisAlignment.center:MainAxisAlignment.spaceBetween,
            mainAxisSize: centerTitle ? MainAxisSize.min:MainAxisSize.max,
            children: [
              if(icon != null && iconIsLeading) icon!,
              if(icon != null && iconIsLeading) const SizedBox(width: 6),
              Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: textColor),),
              if(icon != null && !iconIsLeading) const SizedBox(width: 6),
              if(icon != null && !iconIsLeading) icon!,
            ],
          ),
        ),
      ),
    );
  }
}

class CustomChip extends StatelessWidget {
  const CustomChip(this.text, this.selected, {this.radius = 6, this.onTap, super.key});
  final String text;
  final double radius;
  final void Function()? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: selected ? Theme.of(context).primaryColor : Theme.of(context).bottomNavigationBarTheme.backgroundColor,
      ),
      margin: const EdgeInsets.all(8),
      child: Material(
        borderRadius: BorderRadius.circular(radius),
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Text(text),
          )
        )
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  
  const CustomAppBar({this.title, this.leading, this.actions, this.bgColor, super.key});
  final Widget? leading;
  final Widget? title;
  final List<Widget>? actions;
  final Color? bgColor;

  @override
  Size get preferredSize => const Size.fromHeight(65);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      scrolledUnderElevation: 0, 
      foregroundColor: bgColor ?? Theme.of(context).bottomNavigationBarTheme.backgroundColor ?? const Color(0xFF121212),
      backgroundColor: bgColor ?? Theme.of(context).bottomNavigationBarTheme.backgroundColor ?? const Color(0xFF121212),
      leading: leading,
      title: title,
      centerTitle: true,
      actions: actions,
    );
  }
}

class ButtonShimmer extends StatelessWidget {
  const ButtonShimmer({this.width = 100, super.key});
  final double width;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Shimmer.fromColors(
            baseColor: const Color(0xFF101010),
            highlightColor: Colors.grey.shade900,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF101010),
                borderRadius: BorderRadius.circular(6)
              ),
              height: 16,
              width: width,
            ),
          ),
          Shimmer.fromColors(
            baseColor: const Color(0xFF101010),
            highlightColor: Colors.grey.shade900,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF101010),
                borderRadius: BorderRadius.circular(6)
              ),
              height: 22,
              width: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class MovieShimmer extends StatelessWidget {
  const MovieShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Shimmer.fromColors(
          baseColor: const Color(0xFF101010),
          highlightColor: Colors.grey.shade900,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF101010),
              borderRadius: BorderRadius.circular(12)
            ),
            width: (MediaQuery.of(context).size.width - 20) / 3,
            height: (MediaQuery.of(context).size.width - 20) / 3 / 9 * 12.5 + 1,
          )
        ),
        SizedBox(
          height: 45,
          width: (MediaQuery.of(context).size.width - 20) / 3 - 30,
          child: Center(
            child: Shimmer.fromColors(
              baseColor: const Color(0xFF101010),
              highlightColor: Colors.grey.shade900,
              child: Container(
                width: (MediaQuery.of(context).size.width - 20) / 3 - 20,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFF101010),
                  borderRadius: BorderRadius.circular(6)
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}

class ContainerShimmer extends StatelessWidget {
  const ContainerShimmer({this.width, this.height, this.borderRadius, this.backgroundColor, this.foregroundColor, super.key});
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: backgroundColor ?? const Color(0xFF101010),
      highlightColor: foregroundColor ?? Colors.grey.shade900,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor ?? const Color(0xFF101010),
          borderRadius: borderRadius ?? BorderRadius.circular(6)
        ),
      )
    );
  }
}

class Movie extends StatelessWidget {
  const Movie(this.movie, {super.key});
  final MovieInfo movie;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: (MediaQuery.of(context).size.width - 20) / 3,
          height: (MediaQuery.of(context).size.width - 20) / 3 / 9 * 12.5 + 1,
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ![null, 'null'].contains(movie.poster) ? Image.network(movie.poster!, fit: BoxFit.cover) : Container(
                    color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
                  ),
                ),
              ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => Video(movie)));},
                    onLongPress: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
                        builder: (context) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12))
                            ), 
                            padding: const EdgeInsets.all(5.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: (MediaQuery.of(context).size.width - 20) / 3 / 9 * 12.5 + 1,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: (MediaQuery.of(context).size.width - 20) / 3,
                                        height: (MediaQuery.of(context).size.width - 20) / 3 / 9 * 12.5 + 1,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: movie.poster != null ? Image.network(movie.poster!) : null,
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.all(5),
                                        width: MediaQuery.of(context).size.width - ((MediaQuery.of(context).size.width - 20) / 3) - 20,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(movie.title.toString(), maxLines: 1, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, overflow: TextOverflow.ellipsis),),
                                            const SizedBox(height: 5,),
                                            Text(movie.movie?'Movie  ${movie.year}':'Series  ${movie.year}'),
                                            const SizedBox(height: 5,),
                                            Builder(
                                              builder: (context) {
                                                MovieInfo snapshot = movie;
                                                return GestureDetector(
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) => Dialog(
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                                        backgroundColor: const Color(0xFF121212),
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            color: const Color(0xFF121212),
                                                            borderRadius: BorderRadius.circular(24)
                                                          ),
                                                          padding: const EdgeInsets.all(15),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              const Text('Synopsis', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                                              Text(snapshot.desc.toString())
                                                            ]
                                                          ),
                                                        ),
                                                      )
                                                    );
                                                  },
                                                  child: Text(
                                                    snapshot.desc.toString().trim(),
                                                    maxLines: 6,
                                                    textAlign: TextAlign.left,
                                                    style: const TextStyle(
                                                      overflow: TextOverflow.ellipsis
                                                    ),
                                                  ),
                                                );
                                                // Column(
                                                //   children: List.generate(6, (index) => Shimmer.fromColors(
                                                //     baseColor: const Color(0xFF101010),
                                                //     highlightColor: Colors.grey.shade900,
                                                //     child: Container(
                                                //       margin: const EdgeInsets.all(2),
                                                //       decoration: BoxDecoration(
                                                //         color: const Color(0xFF101010),
                                                //         borderRadius: BorderRadius.circular(6)
                                                //       ),
                                                //       width: (MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width - 20) / 3) - 20,
                                                //       height: 12,
                                                //     ),
                                                //   ),),
                                                // );
                                              }
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Button(
                                  text: 'More info',
                                  onTap: () {Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => Video(movie)));},
                                )
                              ],
                            ),
                          );
                        }
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: (MediaQuery.of(context).size.width - 20) / 3,
          height: 45,
          child: Center(
            child: Text(
              '${movie.title}',
              maxLines: 2,
              textAlign: TextAlign.center,
              style: const TextStyle(overflow: TextOverflow.ellipsis),
            ),
          ),
        ),
      ],
    
    );
  }
}

class IconLabelButton extends StatelessWidget {
  const IconLabelButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.textStyle,
    super.key
  });
  final Widget icon;
  final void Function()? onTap;
  final String label;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: icon,
          onPressed: onTap,
        ),
        Text(label, style: textStyle)
      ],
    );
  }
}
class PersonWidget extends StatelessWidget {
  const PersonWidget(this.name, this.character, this.image, {super.key});
  final String name;
  final String character;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(foregroundImage: image != 'null' ? Image.network('https://image.tmdb.org/t/p/original$image').image : null),
        Text(name, textAlign: TextAlign.center),
        // Text(character, style: const TextStyle(color: Colors.white38)),
      ],
    );
  }
}

class EpisodeButton extends StatelessWidget {
  const EpisodeButton({this.width, required this.title, required this.onTap, required this.onDownloadTap, super.key});
  final double? width;
  final String title;
  final void Function() onTap;
  final void Function() onDownloadTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        onLongPress: () {},//TODO
        child: Container(
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.play_arrow_rounded),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.95 - 48 - 34,
                    child: Text(title, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              IconButton(
                icon: PictureIcon('assets/download.png'),
                onPressed: onDownloadTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PageIndicator extends StatelessWidget {
  const PageIndicator(this.selectedIndex, this.itemCount, {super.key});
  final int selectedIndex;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        itemCount,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: selectedIndex == index ? 30 : 15,
          height: 15,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: selectedIndex == index ? Theme.of(context).primaryColor:Theme.of(context).primaryColor.withOpacity(.6)
          ),

        )
      )
    );
  }
}

class ParallaxFlowDelegate extends FlowDelegate {
  ParallaxFlowDelegate({
    required this.scrollable,
    required this.listItemContext,
    required this.backgroundImageKey,
  }) : super(repaint: scrollable.position);


  final ScrollableState scrollable;
  final BuildContext listItemContext;
  final GlobalKey backgroundImageKey;

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    return BoxConstraints.tightFor(
      width: constraints.maxWidth + 50,
    );
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    // Calculate the position of this list item within the viewport.
    final scrollableBox = scrollable.context.findRenderObject() as RenderBox;
    final listItemBox = listItemContext.findRenderObject() as RenderBox;
    final listItemOffset = listItemBox.localToGlobal(
      listItemBox.size.centerLeft(const Offset(50 * 3.5, 0)),
      ancestor: scrollableBox
    );

    // Determine the percent position of this list item within the
    // scrollable area.
    final viewportDimension = scrollable.position.viewportDimension;
    final scrollFraction = (listItemOffset.dx / viewportDimension).clamp(0.0, 1.0);

    // Calculate the vertical alignment of the background
    // based on the scroll percent.
    final verticalAlignment = Alignment(scrollFraction * 2 - 1, 0.0);

    // Convert the background alignment into a pixel offset for
    // painting purposes.
    final backgroundSize = (backgroundImageKey.currentContext!.findRenderObject() as RenderBox).size;
    final listItemSize = context.size;
    final childRect = verticalAlignment.inscribe(backgroundSize, Offset.zero & listItemSize);

    // Paint the background.
    context.paintChild(
      0,
      transform: Transform.translate(offset: Offset(childRect.left, 0.0)).transform,
    );
  }

  @override
  bool shouldRepaint(ParallaxFlowDelegate oldDelegate) {
    return scrollable != oldDelegate.scrollable ||
        listItemContext != oldDelegate.listItemContext ||
        backgroundImageKey != oldDelegate.backgroundImageKey;
  }
}

class Parallax extends SingleChildRenderObjectWidget {
  const Parallax({
    super.key,
    required Widget background,
  }) : super(child: background);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderParallax(scrollable: Scrollable.of(context));
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderParallax renderObject) {
    renderObject.scrollable = Scrollable.of(context);
  }
}

class ParallaxParentData extends ContainerBoxParentData<RenderBox> {}

class RenderParallax extends RenderBox
    with RenderObjectWithChildMixin<RenderBox>, RenderProxyBoxMixin {
  RenderParallax({
    required ScrollableState scrollable,
  }) : _scrollable = scrollable;

  ScrollableState _scrollable;

  ScrollableState get scrollable => _scrollable;

  set scrollable(ScrollableState value) {
    if (value != _scrollable) {
      if (attached) {
        _scrollable.position.removeListener(markNeedsLayout);
      }
      _scrollable = value;
      if (attached) {
        _scrollable.position.addListener(markNeedsLayout);
      }
    }
  }

  @override
  void attach(covariant PipelineOwner owner) {
    super.attach(owner);
    _scrollable.position.addListener(markNeedsLayout);
  }

  @override
  void detach() {
    _scrollable.position.removeListener(markNeedsLayout);
    super.detach();
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! ParallaxParentData) {
      child.parentData = ParallaxParentData();
    }
  }

  @override
  void performLayout() {
    size = constraints.biggest;

    // Force the background to take up all available width
    // and then scale its height based on the image's aspect ratio.
    final background = child!;
    final backgroundImageConstraints = BoxConstraints.tightFor(height: size.height);
    background.layout(backgroundImageConstraints, parentUsesSize: true);

    // Set the background's local offset, which is zero.
    (background.parentData as ParallaxParentData).offset = Offset.zero;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // Get the size of the scrollable area.
    final viewportDimension = scrollable.position.viewportDimension;

    // Calculate the global position of this list item.
    final scrollableBox = scrollable.context.findRenderObject() as RenderBox;
    final backgroundOffset = localToGlobal(size.topCenter(Offset.zero), ancestor: scrollableBox);

    // Determine the percent position of this list item within the
    // scrollable area.
    final scrollFraction = (backgroundOffset.dx / viewportDimension).clamp(0.0, 1.0);

    // Calculate the vertical alignment of the background
    // based on the scroll percent.
    final verticalAlignment = Alignment(scrollFraction * 2 - 1, 0.0);

    // Convert the background alignment into a pixel offset for
    // painting purposes.
    final background = child!;
    final backgroundSize = background.size;
    final listItemSize = size;
    final childRect =
        verticalAlignment.inscribe(backgroundSize, Offset.zero & listItemSize);

    // Paint the background.
    context.paintChild(
        background,
        (background.parentData as ParallaxParentData).offset +
            offset +
            Offset(childRect.left, 0.0));
  }
}

Size textToSize(String string, TextStyle style) {
  TextPainter textPainter = TextPainter();
  textPainter.text = TextSpan(text: string, style: style);
  textPainter.textDirection = TextDirection.ltr;
  textPainter.layout(minWidth: 0, maxWidth: double.infinity);
  return textPainter.size;
}

double remap(int x, int inMin, int inMax, int outMin, int outMax)
{
  return (x - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
}