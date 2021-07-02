import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_unit/app/router/unit_router.dart';
import 'package:flutter_unit/app/res/toly_icon.dart';
import 'package:flutter_unit/blocs/bloc_exp.dart';
import 'package:flutter_unit/repositories/dao/widget_dao.dart';
import 'package:flutter_unit/views/components/permanent/circle.dart';
import 'package:flutter_unit/views/components/project/default/loading_shower.dart';
import 'package:flutter_unit/model/widget_model.dart';
import 'package:flutter_unit/views/components/project/items/widget/techno_widget_list_item.dart';
import 'package:flutter_unit/views/pages/search/app_search_bar.dart';
import 'package:flutter_unit/views/pages/search/error_page.dart';
import 'package:flutter_unit/views/pages/search/not_search_page.dart';
import 'package:flutter_unit/views/components/permanent/multi_chip_filter.dart';

import '../../components/project/default/empty_shower.dart';


class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          //返回时 情空搜索
          BlocProvider.of<SearchBloc>(context).add(SearchWidgetEvent(args: SearchArgs()));
          return true;
        },
        child: CustomScrollView(
          slivers: <Widget>[
              _buildSliverAppBar(),
            SliverToBoxAdapter(child: _buildStarFilter()),
            BlocBuilder<SearchBloc, SearchState>(builder:_buildBodyByState)
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
            pinned: true,
            title: AppSearchBar(),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: Icon(TolyIcon.icon_sound),
              )
            ],
          );
  }

  Widget _buildStarFilter() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 20, bottom: 5),
            child: Wrap(
              spacing: 5,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Circle(
                  radius: 5,
                  color: Colors.orange,
                ),
                Text(
                  '星级查询',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          MultiChipFilter<int>(
            data: [1, 2, 3, 4, 5],
            avatarBuilder: (_, index) =>
                CircleAvatar(child: Text((index + 1).toString())),
            labelBuilder: (_, selected) => Icon(
              Icons.star,
              color: selected ? Colors.blue : Colors.grey,
              size: 18,
            ),
            onChange: _doSelectStart,
          ),
          Divider(),
          SizedBox(height: 10,)
        ],
      );

  Widget _buildBodyByState(BuildContext context,SearchState state) {
    if (state is SearchStateNoSearch) return SliverToBoxAdapter(child: NotSearchPage(),);
    if (state is SearchStateLoading) return SliverToBoxAdapter(child: LoadingShower());
    if (state is SearchStateError) return SliverToBoxAdapter(child: ErrorPage());
    if (state is SearchStateSuccess) return _buildSliverList(state.result);
    if (state is SearchStateEmpty) return SliverToBoxAdapter(child: EmptyShower(message: "没数据，哥也没办法\n(≡ _ ≡)/~┴┴",));
    return NotSearchPage();
  }

  Widget _buildSliverList(List<WidgetModel> models) => SliverList(
        delegate: SliverChildBuilderDelegate(
            (_, int index) => Container(
                child: InkWell(
                    onTap: () => _toDetailPage(models[index]),
                    child: TechnoWidgetListItem(
                      data: models[index],
                    ))),
            childCount: models.length),
      );

  _doSelectStart(List<int> select) {
    List<int> temp = select.map((e)=>e+1).toList();
    if (temp.length < 5) {
      temp.addAll(List.generate(5 - temp.length, (e) => -1));
    }
    BlocProvider.of<SearchBloc>(context)
        .add(SearchWidgetEvent(args: SearchArgs(name: '', stars: temp)));
  }

  _toDetailPage(WidgetModel model) {
    BlocProvider.of<DetailBloc>(context).add(FetchWidgetDetail(model));
    Navigator.pushNamed(context, UnitRouter.widget_detail,arguments: model);
  }
}
