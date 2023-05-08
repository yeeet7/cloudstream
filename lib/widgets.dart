
// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:movie_provider/movie_provider.dart';
import 'package:shimmer/shimmer.dart';

extension Index<E> on Iterable<E> {
  Iterable<E> mapIndexed(E Function(E e, int index) function) {
    List<E> list = [];
    for (var i = 0; i < length; i++) {
      list.add(function.call(toList()[i], i));
    }
    return list;
  }
}

class PictureIcon extends StatelessWidget {

  PictureIcon(this.path, {this.size = 20, this.color, super.key});
  final String path;
  final double size;
  Color? color;

  @override
  Widget build(BuildContext context) {
    Color? iconColor = color ?? IconTheme.of(context).color;
    return SizedBox(
      width: size,
      height: size,
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
        children: widget.items.mapIndexed((e, index) => widget.selected == index ? (e..selected = true) : (e..selected = false)).toList(),
      ),
    );
  }
}

class BottomNavBarItem extends StatelessWidget {
  
  BottomNavBarItem(this.icon, {required this.onTap, this.selected = false, this.color, this.title = '', super.key});
  final String? title;
  final PictureIcon icon;
  Color? color;
  void Function() onTap;
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
  const Button({required this.text, this.onTap, super.key});
  final String text;
  final void Function()? onTap;
 
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(text, style: const TextStyle(fontWeight: FontWeight.bold),),
              const Icon(Icons.arrow_forward_ios_rounded),
            ],
          ),
        ),
      ),
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
                  child: movie.image,
                ),
              ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {},//TODO
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
                                          child: movie.image,
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
                                            Text('Movie  ${movie.year}'),
                                            const SizedBox(height: 5,),
                                            FutureBuilder(
                                              future: movie.getDetails(),
                                              builder: (context, snapshot) {
                                                return snapshot.data != null ? GestureDetector(
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
                                                              Text(snapshot.data!.desc.toString())
                                                            ]
                                                          ),
                                                        ),
                                                      )
                                                    );
                                                  },
                                                  child: Text(
                                                    snapshot.data!.desc.toString().trim(),
                                                    maxLines: 6,
                                                    textAlign: TextAlign.left,
                                                    style: const TextStyle(
                                                      overflow: TextOverflow.ellipsis
                                                    ),
                                                  ),
                                                ) : 
                                                Column(
                                                  children: List.generate(6, (index) => Shimmer.fromColors(
                                                    baseColor: const Color(0xFF101010),
                                                    highlightColor: Colors.grey.shade900,
                                                    child: Container(
                                                      margin: const EdgeInsets.all(2),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFF101010),
                                                        borderRadius: BorderRadius.circular(6)
                                                      ),
                                                      width: (MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width - 20) / 3) - 20,
                                                      height: 12,
                                                    ),
                                                  ),),
                                                );
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
                                  onTap: () {},//TODO
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

class Series extends StatelessWidget {
  const Series(this.series, {super.key});
  final SeriesInfo series;

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
                  child: series.image,
                ),
              ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {},//TODO
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
                                          child: series.image,
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.all(5),
                                        width: MediaQuery.of(context).size.width - ((MediaQuery.of(context).size.width - 20) / 3) - 20,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(series.title.toString(), maxLines: 1, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, overflow: TextOverflow.ellipsis),),
                                            const SizedBox(height: 5,),
                                            Text('Movie  ${series.year}'),
                                            const SizedBox(height: 5,),
                                            FutureBuilder(
                                              future: series.getDetails(),
                                              builder: (context, snapshot) {
                                                return snapshot.data != null ? GestureDetector(
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) => Dialog(
                                                        backgroundColor: const Color(0xFF121212),
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                                                              Text(snapshot.data!.desc.toString())
                                                            ]
                                                          ),
                                                        ),
                                                      )
                                                    );
                                                  },
                                                  child: Text(
                                                    snapshot.data!.desc.toString().trim(),
                                                    maxLines: 6,
                                                    textAlign: TextAlign.left,
                                                    style: const TextStyle(
                                                      overflow: TextOverflow.ellipsis
                                                    ),
                                                  ),
                                                ) : 
                                                Column(
                                                  children: List.generate(6, (index) => Shimmer.fromColors(
                                                    baseColor: const Color(0xFF101010),
                                                    highlightColor: Colors.grey.shade900,
                                                    child: Container(
                                                      margin: const EdgeInsets.all(2),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFF101010),
                                                        borderRadius: BorderRadius.circular(6)
                                                      ),
                                                      width: (MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width - 20) / 3) - 20,
                                                      height: 12,
                                                    ),
                                                  ),),
                                                );
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
                                  onTap: () {},//TODO
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
              '${series.title}',
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