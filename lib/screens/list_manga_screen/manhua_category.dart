import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangamint/bloc/manhuamanhwa/bloc.dart';
import 'package:mangamint/components/bottom_loader.dart';
import 'package:mangamint/components/my_shimmer.dart';
import 'package:mangamint/constants/base_color.dart';
import 'package:flutter/material.dart';
import 'package:mangamint/helper/color_manga_type.dart';

class ManhuaCategory extends StatefulWidget {
  @override
  _ManhuaCategoryState createState() => _ManhuaCategoryState();
}

class _ManhuaCategoryState extends State<ManhuaCategory> {
  ManhuamanhwaBloc _manhuamanhwaBloc;
  final _scrollCtrl = ScrollController();
  final _scrollThreshold = 200.0;
  @override
  void initState() {
    super.initState();
    _manhuamanhwaBloc = BlocProvider.of<ManhuamanhwaBloc>(context)
    ..add(FetchManhua());
    _scrollCtrl.addListener(() {
      final maxScroll = _scrollCtrl.position.maxScrollExtent;
      final currentScroll = _scrollCtrl.position.pixels;
      if (maxScroll - currentScroll <= _scrollThreshold) {
        _manhuamanhwaBloc = BlocProvider.of<ManhuamanhwaBloc>(context);
        _manhuamanhwaBloc.add(FetchManhua(endpoint: 'manhua'));
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init();
    return Padding(
      padding: EdgeInsets.all(8),
      child: BlocBuilder<ManhuamanhwaBloc,ManhuamanhwaState>(
        builder: (context,state){
          if(state is ManhuaManhwaLoadingState){
            return MyShimmer(
              child: ListView.builder(
                itemCount: 10,
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context,i){
                  return ListTile(
                    leading: Container(
                      height: 100.h,
                      width: 200.w,
                      color: BaseColor.red,
                    ),
                    title: Container(
                      height: 100.h,
                      width:MediaQuery.of(context).size.width,
                      color: BaseColor.red,
                    ),
                  );
                },
              ),
            );
          }else if(state is ManhuaLoadedState){
            return Scrollbar(
              child: ListView.builder(
                itemCount: state.hasReachedMax
                    ? state.list.length
                    : state.list.length + 1,
                controller: _scrollCtrl,
                itemBuilder: (context, i) {
                  return i >= state.list.length
                      ? BottomLoader()
                      : ListTile(
                    onTap: (){
                      Navigator.pushNamed(context, '/detailmanga',arguments:
                      state.list[i].endpoint);
                    },
                    title: Text(state.list[i].title.length > 20
                        ? '${state.list[i].title.substring(0, 20)}..'
                        : state.list[i].title),
                    subtitle: Text(state.list[i].type,style: TextStyle(
                        color: mangaTypeColor(state.list[i].type)
                    ),),
                    leading: Image.network(
                      state.list[i].thumb,
                      height: MediaQuery.of(context).size.height,
                      width: 200.w,
                      fit: BoxFit.cover,
                    ),
                    trailing: SizedBox(
                      height: 100.h,
                      width: 200.w,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.star,color: BaseColor.orange,),
                          Text(state.list[i].score.toString(),style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _ratingColor(state.list[i].score)
                          ),),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return Container();
        },
      ),
    );
  }
  Color _ratingColor(num score){
    if(score < 7){
      return BaseColor.red;
    }else if (score >= 7 && score <= 8.5) {
      return BaseColor.green;
    }else if(score >= 8.6){
      return BaseColor.orange;
    }else{
      return BaseColor.grey1;
    }
  }
}
