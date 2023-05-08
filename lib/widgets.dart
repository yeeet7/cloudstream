
// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:movie_provider/movie_provider.dart';

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
      child: Image.asset(path, color: iconColor),
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
                    onTap: () async {
                      print('vidsrc: ${movie.vidurl}');
                    },
                    onLongPress: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: (MediaQuery.of(context).size.width - 20) / 3,
                                    height: (MediaQuery.of(context).size.width - 20) / 3 / 9 * 12.5 + 1,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: movie.image,
                                  ),
                                  Column(
                                    children: [
                                      Text(movie.title.toString()),
                                      Text(movie.year.toString()),
                                    ],
                                  )
                                ],
                              )
                            ],
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