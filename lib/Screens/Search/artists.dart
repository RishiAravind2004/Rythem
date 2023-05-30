/*
 *  This file is part of Rythem (https://github.com/RishiAravind2004/Rythem).
 * 
 * Rythem is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Rythem is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with Rythem.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * Copyright (c) 2021-2022, Ankit Sangwan
 */

import 'package:rythem/APIs/api.dart';
import 'package:rythem/CustomWidgets/artist_like_button.dart';
import 'package:rythem/CustomWidgets/bouncy_sliver_scroll_view.dart';
import 'package:rythem/CustomWidgets/copy_clipboard.dart';
import 'package:rythem/CustomWidgets/download_button.dart';
import 'package:rythem/CustomWidgets/empty_screen.dart';
import 'package:rythem/CustomWidgets/gradient_containers.dart';
import 'package:rythem/CustomWidgets/horizontal_albumlist.dart';
import 'package:rythem/CustomWidgets/like_button.dart';
import 'package:rythem/CustomWidgets/miniplayer.dart';
import 'package:rythem/CustomWidgets/playlist_popupmenu.dart';
import 'package:rythem/CustomWidgets/snackbar.dart';
import 'package:rythem/CustomWidgets/song_tile_trailing_menu.dart';
import 'package:rythem/Helpers/image_resolution_modifier.dart';
import 'package:rythem/Screens/Common/song_list.dart';
import 'package:rythem/Services/player_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

class ArtistSearchPage extends StatefulWidget {
  final Map data;

  const ArtistSearchPage({
    super.key,
    required this.data,
  });

  @override
  _ArtistSearchPageState createState() => _ArtistSearchPageState();
}

class _ArtistSearchPageState extends State<ArtistSearchPage> {
  bool status = false;
  String category = '';
  String sortOrder = '';
  Map<String, List> data = {};
  bool fetched = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!status) {
      status = true;
      SaavnAPI()
          .fetchArtistSongs(
        artistToken: widget.data['artistToken'].toString(),
        category: category,
        sortOrder: sortOrder,
      )
          .then((value) {
        setState(() {
          data = value;
          fetched = true;
        });
      });
    }
    return GradientContainer(
      child: Column(
        children: [
          Expanded(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: !fetched
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : data.isEmpty
                      ? emptyScreen(
                          context,
                          0,
                          ':( ',
                          100,
                          AppLocalizations.of(context)!.sorry,
                          60,
                          AppLocalizations.of(context)!.resultsNotFound,
                          20,
                        )
                      : BouncyImageSliverScrollView(
                          scrollController: _scrollController,
                          actions: [
                            IconButton(
                              icon: const Icon(Icons.share_rounded),
                              tooltip: AppLocalizations.of(context)!.share,
                              onPressed: () {
                                Share.share(
                                  widget.data['perma_url'].toString(),
                                );
                              },
                            ),
                            ArtistLikeButton(
                              data: widget.data,
                              size: 27.0,
                            ),
                            if (data['Top Songs'] != null)
                              PlaylistPopupMenu(
                                data: data['Top Songs']!,
                                title:
                                    widget.data['title']?.toString() ?? 'Songs',
                              ),
                          ],
                          title: widget.data['title']?.toString() ??
                              AppLocalizations.of(context)!.songs,
                          placeholderImage: 'assets/artist.png',
                          imageUrl:
                              getImageUrl(widget.data['image'].toString()),
                          sliverList: SliverList(
                            delegate: SliverChildListDelegate(
                              [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            PlayerInvoke.init(
                                              songsList: data['Top Songs']!,
                                              index: 0,
                                              isOffline: false,
                                            );
                                            Navigator.pushNamed(
                                              context,
                                              '/player',
                                            );
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                              top: 10,
                                              bottom: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(100.0),
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 5.0,
                                                  offset: Offset(0.0, 3.0),
                                                )
                                              ],
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 10.0,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.play_arrow_rounded,
                                                    color: Theme.of(context)
                                                                .colorScheme
                                                                .secondary ==
                                                            Colors.white
                                                        ? Colors.black
                                                        : Colors.white,
                                                    size: 26.0,
                                                  ),
                                                  const SizedBox(width: 5.0),
                                                  Text(
                                                    AppLocalizations.of(
                                                      context,
                                                    )!
                                                        .play,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18.0,
                                                      color: Theme.of(context)
                                                                  .colorScheme
                                                                  .secondary ==
                                                              Colors.white
                                                          ? Colors.black
                                                          : Colors.white,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            ShowSnackBar().showSnackBar(
                                              context,
                                              AppLocalizations.of(
                                                context,
                                              )!
                                                  .connectingRadio,
                                              duration: const Duration(
                                                seconds: 2,
                                              ),
                                            );
                                            SaavnAPI().createRadio(
                                              names: [
                                                widget.data['title']
                                                        ?.toString() ??
                                                    '',
                                              ],
                                              language: widget.data['language']
                                                      ?.toString() ??
                                                  'hindi',
                                              stationType: 'artist',
                                            ).then((value) {
                                              if (value != null) {
                                                SaavnAPI()
                                                    .getRadioSongs(
                                                  stationId: value,
                                                )
                                                    .then((value) {
                                                  PlayerInvoke.init(
                                                    songsList: value,
                                                    index: 0,
                                                    isOffline: false,
                                                  );
                                                  Navigator.pushNamed(
                                                    context,
                                                    '/player',
                                                  );
                                                });
                                              }
                                            });
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(100.0),
                                              border: Border.all(
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 10.0,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.podcasts_rounded,
                                                    color: Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? Colors.white
                                                        : Colors.black,
                                                    size: 26.0,
                                                  ),
                                                  const SizedBox(width: 5.0),
                                                  Text(
                                                    AppLocalizations.of(
                                                      context,
                                                    )!
                                                        .radio,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18.0,
                                                      color: Theme.of(context)
                                                                  .brightness ==
                                                              Brightness.dark
                                                          ? Colors.white
                                                          : Colors.black,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Container(
                                        margin: const EdgeInsets.only(
                                          top: 10,
                                          bottom: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100.0),
                                          border: Border.all(
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: GestureDetector(
                                            child: Icon(
                                              Icons.shuffle_rounded,
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black,
                                              size: 24.0,
                                            ),
                                            onTap: () {
                                              PlayerInvoke.init(
                                                songsList: data['Top Songs']!,
                                                index: 0,
                                                isOffline: false,
                                                shuffle: true,
                                              );
                                              Navigator.pushNamed(
                                                context,
                                                '/player',
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ...data.entries.map(
                                  (entry) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 25,
                                            top: 15,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                entry.key,
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              if (entry.key ==
                                                  'Top Songs') ...<Widget>[
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    ChoiceChip(
                                                      label: Text(
                                                        AppLocalizations.of(
                                                          context,
                                                        )!
                                                            .popularity,
                                                      ),
                                                      selectedColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .secondary
                                                              .withOpacity(0.2),
                                                      labelStyle: TextStyle(
                                                        color: category == ''
                                                            ? Theme.of(context)
                                                                .colorScheme
                                                                .secondary
                                                            : Theme.of(context)
                                                                .textTheme
                                                                .bodyLarge!
                                                                .color,
                                                        fontWeight: category ==
                                                                ''
                                                            ? FontWeight.w600
                                                            : FontWeight.normal,
                                                      ),
                                                      selected: category == '',
                                                      onSelected:
                                                          (bool selected) {
                                                        if (selected) {
                                                          category = '';
                                                          sortOrder = '';
                                                          status = false;
                                                          setState(() {});
                                                        }
                                                      },
                                                    ),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    ChoiceChip(
                                                      label: Text(
                                                        AppLocalizations.of(
                                                          context,
                                                        )!
                                                            .date,
                                                      ),
                                                      selectedColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .secondary
                                                              .withOpacity(0.2),
                                                      labelStyle: TextStyle(
                                                        color: category ==
                                                                'latest'
                                                            ? Theme.of(context)
                                                                .colorScheme
                                                                .secondary
                                                            : Theme.of(context)
                                                                .textTheme
                                                                .bodyLarge!
                                                                .color,
                                                        fontWeight: category ==
                                                                'latest'
                                                            ? FontWeight.w600
                                                            : FontWeight.normal,
                                                      ),
                                                      selected:
                                                          category == 'latest',
                                                      onSelected:
                                                          (bool selected) {
                                                        if (selected) {
                                                          category = 'latest';
                                                          sortOrder = 'desc';
                                                          status = false;
                                                          setState(() {});
                                                        }
                                                      },
                                                    ),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    ChoiceChip(
                                                      label: Text(
                                                        AppLocalizations.of(
                                                          context,
                                                        )!
                                                            .alphabetical,
                                                      ),
                                                      selectedColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .secondary
                                                              .withOpacity(0.2),
                                                      labelStyle: TextStyle(
                                                        color: category ==
                                                                'alphabetical'
                                                            ? Theme.of(context)
                                                                .colorScheme
                                                                .secondary
                                                            : Theme.of(context)
                                                                .textTheme
                                                                .bodyLarge!
                                                                .color,
                                                        fontWeight: category ==
                                                                'alphabetical'
                                                            ? FontWeight.w600
                                                            : FontWeight.normal,
                                                      ),
                                                      selected: category ==
                                                          'alphabetical',
                                                      onSelected:
                                                          (bool selected) {
                                                        if (selected) {
                                                          category =
                                                              'alphabetical';
                                                          sortOrder = 'asc';
                                                          status = false;
                                                          setState(() {});
                                                        }
                                                      },
                                                    ),
                                                    const Spacer(),
                                                    // removed as it wasn't useful
                                                    // if (data['Top Songs'] !=
                                                    //     null)
                                                    // MultiDownloadButton(
                                                    //   data:
                                                    //       data['Top Songs']!,
                                                    //   playlistName: widget
                                                    //           .data['title']
                                                    //           ?.toString() ??
                                                    //       'Songs',
                                                    // ),
                                                    // const SizedBox(
                                                    //   width: 5,
                                                    // ),
                                                  ],
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        if (entry.key != 'Top Songs')
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                              5,
                                              10,
                                              5,
                                              0,
                                            ),
                                            child: HorizontalAlbumsList(
                                              songsList: entry.value,
                                              onTap: (int idx) {
                                                Navigator.push(
                                                  context,
                                                  PageRouteBuilder(
                                                    opaque: false,
                                                    pageBuilder: (
                                                      _,
                                                      __,
                                                      ___,
                                                    ) =>
                                                        entry.key ==
                                                                'Related Artists'
                                                            ? ArtistSearchPage(
                                                                data: entry
                                                                        .value[
                                                                    idx] as Map,
                                                              )
                                                            : SongsListPage(
                                                                listItem: entry
                                                                        .value[
                                                                    idx] as Map,
                                                              ),
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                        else
                                          ListView.builder(
                                            itemCount: entry.value.length,
                                            padding: const EdgeInsets.fromLTRB(
                                              5,
                                              5,
                                              5,
                                              0,
                                            ),
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemBuilder: (context, index) {
                                              return ListTile(
                                                contentPadding:
                                                    const EdgeInsets.only(
                                                  left: 15.0,
                                                ),
                                                title: Text(
                                                  '${entry.value[index]["title"]}',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                onLongPress: () {
                                                  copyToClipboard(
                                                    context: context,
                                                    text:
                                                        '${entry.value[index]["title"]}',
                                                  );
                                                },
                                                subtitle: Text(
                                                  '${entry.value[index]["subtitle"]}',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                leading: Card(
                                                  margin: EdgeInsets.zero,
                                                  elevation: 8,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      7.0,
                                                    ),
                                                  ),
                                                  clipBehavior: Clip.antiAlias,
                                                  child: CachedNetworkImage(
                                                    fit: BoxFit.cover,
                                                    errorWidget:
                                                        (context, _, __) =>
                                                            Image(
                                                      fit: BoxFit.cover,
                                                      image: AssetImage(
                                                        (entry.key ==
                                                                    'Top Songs' ||
                                                                entry.key ==
                                                                    'Latest Release')
                                                            ? 'assets/cover.jpg'
                                                            : 'assets/album.png',
                                                      ),
                                                    ),
                                                    imageUrl:
                                                        '${entry.value[index]["image"].replaceAll('http:', 'https:')}',
                                                    placeholder:
                                                        (context, url) => Image(
                                                      fit: BoxFit.cover,
                                                      image: AssetImage(
                                                        (entry.key ==
                                                                    'Top Songs' ||
                                                                entry.key ==
                                                                    'Latest Release' ||
                                                                entry.key ==
                                                                    'Singles')
                                                            ? 'assets/cover.jpg'
                                                            : 'assets/album.png',
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                trailing: (entry.key ==
                                                            'Top Songs' ||
                                                        entry.key ==
                                                            'Latest Release' ||
                                                        entry.key == 'Singles')
                                                    ? Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          DownloadButton(
                                                            data: entry.value[
                                                                index] as Map,
                                                            icon: 'download',
                                                          ),
                                                          LikeButton(
                                                            data: entry.value[
                                                                index] as Map,
                                                            mediaItem: null,
                                                          ),
                                                          SongTileTrailingMenu(
                                                            data: entry.value[
                                                                index] as Map,
                                                          ),
                                                        ],
                                                      )
                                                    : null,
                                                onTap: () {
                                                  if (entry.key ==
                                                          'Top Songs' ||
                                                      entry.key ==
                                                          'Latest Release' ||
                                                      entry.key == 'Singles') {
                                                    PlayerInvoke.init(
                                                      songsList: entry.value,
                                                      index: index,
                                                      isOffline: false,
                                                    );
                                                  }
                                                  (entry.key == 'Top Songs' ||
                                                          entry.key ==
                                                              'Latest Release' ||
                                                          entry.key ==
                                                              'Singles')
                                                      ? Navigator.pushNamed(
                                                          context,
                                                          '/player',
                                                        )
                                                      : Navigator.push(
                                                          context,
                                                          PageRouteBuilder(
                                                            opaque: false,
                                                            pageBuilder: (
                                                              _,
                                                              __,
                                                              ___,
                                                            ) =>
                                                                SongsListPage(
                                                              listItem: entry
                                                                      .value[
                                                                  index] as Map,
                                                            ),
                                                          ),
                                                        );
                                                },
                                              );
                                            },
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
            ),
          ),
          MiniPlayer(),
        ],
      ),
    );
  }
}
