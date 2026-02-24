import 'package:PiliPlus/features/fav/presentation/pages/fav_article_page.dart';
import 'package:PiliPlus/features/fav/presentation/pages/fav_cheese_page.dart';
import 'package:PiliPlus/features/fav/presentation/pages/fav_note_page.dart';
import 'package:PiliPlus/features/fav/presentation/pages/fav_pgc_page.dart';
import 'package:PiliPlus/features/fav/presentation/pages/fav_topic_page.dart';
import 'package:PiliPlus/features/fav/presentation/pages/fav_video_page.dart';
import 'package:flutter/material.dart';

enum FavTabType {
  video('视频', FavVideoPage()),
  bangumi('追番', FavPgcPage(type: 1)),
  cinema('追剧', FavPgcPage(type: 2)),
  article('专栏', FavArticlePage()),
  note('笔记', FavNotePage()),
  topic('话题', FavTopicPage()),
  cheese('课堂', FavCheesePage())
  ;

  final String title;
  final Widget page;
  const FavTabType(this.title, this.page);
}
