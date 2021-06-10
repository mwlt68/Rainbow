import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rainbow/core/core_models/core_status_model.dart';
import 'package:rainbow/views/main_views/status/user_statuses_model.dart';
import 'package:rainbow/views/main_views/status/status_view_model.dart';
import 'package:story_view/story_view.dart';



class StateViewDelegate extends StatefulWidget {
  
  UserStatusesModel userStatusesModel;
  
  StateViewDelegate(this.userStatusesModel);

  @override
  _StateViewDelegateState createState() => _StateViewDelegateState();
}

class _StateViewDelegateState extends State<StateViewDelegate> {
  final StoryController controller = StoryController();
  StatusViewModel _viewModel;
  List<StoryItem> storyItems = [];
  int duration=3;
  String when = "";

  @override
  void initState() {
    super.initState();
    _viewModel= new  StatusViewModel();
    widget.userStatusesModel.statuses.forEach((status) {
      if (status.mediaType == StatusMediaType.Text.index) {
        storyItems.add(
          StoryItem.text(
            title: status.caption ?? "",
            backgroundColor: Colors.blueAccent,
            duration: Duration(
              milliseconds: (duration * 1000).toInt(),
            ),
          ),
        );
      }

      if (status.mediaType == StatusMediaType.Image.index) {
        storyItems.add(StoryItem.pageImage(
          url: status.src,
          controller: controller,
          caption: status.caption ,
          duration: Duration(
            milliseconds: (duration* 1000).toInt(),
          ),
        ));
      }

      if (status.mediaType == StatusMediaType.Video.index) {
        storyItems.add(
          StoryItem.pageVideo(
            status.src,
            controller: controller,
            duration: Duration(milliseconds: (duration * 1000).toInt()),
            caption: status.caption ,
          ),
        );
      }
    });
    var timeDifference=widget.userStatusesModel.statuses[0].timeDifferenceInMinutes;
    when = _viewModel.timeDifferenceText(timeDifference);
  }

  Widget _buildProfileView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CircleAvatar(
          radius: 24,
          backgroundImage: CachedNetworkImageProvider(
              widget.userStatusesModel.user.imgSrcWithDefault),
        ),
        SizedBox(
          width: 16,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.userStatusesModel.user.name,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Text(
                when,
                style: TextStyle(
                  color: Colors.white38,
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          StoryView(
            storyItems: storyItems,
            controller: controller,
            onComplete: () {
              Navigator.of(context).pop();
            },
            onVerticalSwipeComplete: (v) {
              if (v == Direction.down) {
                Navigator.pop(context);
              }
            },
            onStoryShow: (storyItem) {
              int pos = storyItems.indexOf(storyItem);

              // the reason for doing setState only after the first
              // position is becuase by the first iteration, the layout
              // hasn't been laid yet, thus raising some exception
              // (each child need to be laid exactly once)
              if (pos > 0) {
                setState(() {
                  var timeDifference=widget.userStatusesModel.statuses[pos].timeDifferenceInMinutes;
                  when =_viewModel.timeDifferenceText(timeDifference);
                });
              }
            },
          ),
          Container(
            padding: EdgeInsets.only(
              top: 48,
              left: 16,
              right: 16,
            ),
            child: _buildProfileView(),
          )
        ],
      ),
    );
  }


}