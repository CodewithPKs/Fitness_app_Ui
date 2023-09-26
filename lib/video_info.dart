import 'dart:convert';
import 'dart:math';

import 'package:fittness_app/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class VideoInfo extends StatefulWidget {
  const VideoInfo({Key? key}) : super(key: key);

  @override
  State<VideoInfo> createState() => _VideoInfoState();
}

class _VideoInfoState extends State<VideoInfo> {

  List videoInfo = [];
  bool _playArea = false;
  bool _isPlaying = false;
  bool _dispose = false;
  VideoPlayerController? _controller;
  int _isPlayingIndex = -1;

  _initData() async {
   await DefaultAssetBundle.of(context).loadString("json/video_info.json").then((value) {
      setState(() {
        videoInfo = json.decode(value);
      });
    });
  }

  @override
  void initState(){
    super.initState();
    _initData();
  }

  @override
  void dispose(){
    _dispose = true;
    _controller?.pause();
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: _playArea==false?BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColor.gradientFirst.withOpacity(0.8),
              AppColor.gradientSecond
            ],
            begin: const FractionalOffset(0.0, 0.4),
            end: Alignment.topRight
          )
        ):BoxDecoration(
          color: AppColor.gradientSecond
        ),
        child: Column(
          children: [
            _playArea == false?Container(
              padding: const EdgeInsets.only(top: 70, left: 30, right: 30),
              width: MediaQuery.of(context).size.width,
              height: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: (){
                          Get.back();
                        },
                        child: Icon(Icons.arrow_back_ios, size: 20, color: AppColor.secondPageIconColor),
                      ),
                      Expanded(child: Container()),
                      Icon(Icons.info_outline_rounded, size: 20, color: AppColor.secondPageIconColor,),
                    ],
                  ),
                  const SizedBox(height: 30,),
                  Text('Legs Toning',
                    style: TextStyle(
                        fontSize: 25,
                        color: AppColor.secondPageTitleColor
                    ),
                  ),
                  const SizedBox(height: 5,),
                  Text('and Glutes Workout',
                    style: TextStyle(
                        fontSize: 25,
                        color: AppColor.secondPageTitleColor
                    ),
                  ),
                  const SizedBox(height: 50,),
                  Row(
                    children: [
                      Container(
                        width: 90,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: [
                              AppColor.secondPageContainerGradient1stColor,
                              AppColor.secondPageContainerGradient2ndColor
                            ],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight
                          )
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.timer, size: 20, color: AppColor.secondPageIconColor,),
                            const SizedBox(width: 5,),
                            Text("68 min",
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColor.secondPageIconColor
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(child: Container()),
                      Container(
                        width: 250,
                        height: 30,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                                colors: [
                                  AppColor.secondPageContainerGradient1stColor,
                                  AppColor.secondPageContainerGradient2ndColor
                                ],
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight
                            )
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.handyman_outlined, size: 20, color: AppColor.secondPageIconColor,),
                            SizedBox(width: 5,),
                            Text("Resistent band, Kettlebell",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: AppColor.secondPageIconColor
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ):Container(
             child: Column(
               children: [
                 Container(
                   padding: const EdgeInsets.only(top: 50, left: 30, right: 30),
                   height: 100,
                   child: Row(
                     children: [
                       InkWell(
                         onTap: (){
                           Get.back();
                         },
                         child: Icon(Icons.arrow_back,
                           size: 20,
                           color: AppColor.secondPageIconColor,
                         ),
                       ),
                       Expanded(child: Container()),
                       Icon(Icons.info_outline,
                       size: 20,
                       color: AppColor.secondPageIconColor
                         ,)
                     ],
                   ),
                 ),
                 _playView(context),
                 _controlView(context),
               ],
             ),
            ),
            Expanded(child: Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(70)
                )
              ),
              child: Column(
                children: [
                  const SizedBox(height: 30,),
                  Row(
                    children: [
                      const SizedBox(width: 30,),
                      Text("Circuit 1 : Legs Toning",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColor.circuitsColor
                        ),
                      ),
                      Expanded(child: Container()),
                      Row(
                        children: [
                          Icon(Icons.loop_outlined, size: 20, color: AppColor.loopColor,),
                          const SizedBox(width: 10,),
                          Text("3 sets",
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColor.setsColor
                            ),
                          )
                        ],
                      ),
                      const SizedBox(width: 20,)
                    ],
                  ),
                  const SizedBox(height: 20,),
                  Expanded(
                      child: _listView())
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  String convertTwo(int value){
    return value < 10 ? "0$value" : "$value";
  }

  //=====control the video with buttons==============
  Widget _controlView(BuildContext context){
    final noMute = (_controller?.value?.volume??0)>0;
    final duration = _duration?.inSeconds??0;
    final head = _position?.inSeconds ?? 0;
    final remaind = max(0, duration - head);
    final mins = convertTwo(remaind ~/ 60.0);
    final secs = convertTwo(remaind % 60);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SliderTheme(
            data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.red[700],
                inactiveTrackColor: Colors.red[100],
                trackShape: const RoundedRectSliderTrackShape(),
                trackHeight: 2.0,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
                thumbColor: Colors.redAccent,
                overlayColor: Colors.red.withAlpha(32),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 28.0),
                tickMarkShape: const RoundSliderTickMarkShape(),
                activeTickMarkColor: Colors.red[700],
                inactiveTickMarkColor: Colors.red[100],
                valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                valueIndicatorColor: Colors.redAccent,
                valueIndicatorTextStyle: const TextStyle(
                    color: Colors.white
                )
            ),
            child: Slider(
              value: max(0, min(_progress * 100, 100)),
              min: 0,
              max: 100,
              divisions: 100,
              label: _position?.toString().split(".")[0],
              onChanged: (value){
                setState(() {
                  _progress = value * 0.01;
                });
              },
              onChangeStart: (value){
                _controller?.pause();
              },
              onChangeEnd: (value){
                final duration = _controller?.value?.duration;
                if(duration != null){
                  var newValue = max(0, min(value, 99)) * 0.01;
                  var millis = (duration.inMilliseconds * newValue).toInt();
                  _controller?.seekTo(Duration(milliseconds: millis));
                  _controller?.play();
                }
              },
            )
        ),
        Container(
      height: 40,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(bottom: 5),
      color: AppColor.gradientSecond,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          InkWell(
            onTap: (){
              if(noMute){
                _controller?.setVolume(0);
              } else {
                _controller?.setVolume(1.0);
              }
              setState(() {
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Container(
                decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          offset: Offset(0.0, 0.0),
                          blurRadius: 4.0,
                          color: Color.fromARGB(50, 0, 0, 0)
                      )
                    ]
                ),
                child: Icon(
                  noMute?Icons.volume_up:Icons.volume_off,
                  color: Colors.white,),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final index = _isPlayingIndex-1;
              if(index>=0&&videoInfo.length>=0){
                _onTapVideo(index);
              } else {
                Get.snackbar("Video", "",
                    snackPosition: SnackPosition.BOTTOM,
                    icon: const Icon(Icons.face, size: 30, color: Colors.white),
                    backgroundColor: AppColor.gradientSecond.withOpacity(0.9),
                    colorText: Colors.white,
                    messageText: const Text("No any previous video left !",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white
                      ),
                    )
                );
              }
            },
            child: const Icon(Icons.fast_rewind,
              size: 36,
              color: Colors.white,
            ),
          ),
          TextButton(
            onPressed: () async{
              if(_isPlaying){
                setState(() {
                  _isPlaying = false;
                });
                _controller?.pause();
              } else {
                setState(() {
                  _isPlaying = true;
                });
                _controller?.play();
              }
            },
            child: Icon(_isPlaying?Icons.pause:Icons.play_arrow,
              size: 36,
              color: Colors.white,
            ),
          ),
          TextButton(
            onPressed: () {
              final index = _isPlayingIndex+1;
              if(index<=videoInfo.length-1){
                _onTapVideo(index);
              } else {
                Get.snackbar("Video", "",
                    snackPosition: SnackPosition.BOTTOM,
                    icon: const Icon(Icons.face, size: 30, color: Colors.white),
                    backgroundColor: AppColor.gradientSecond.withOpacity(0.9),
                    colorText: Colors.white,
                    messageText: const Text("No any next video left !",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white
                      ),
                    )
                );
              }
            },
            child: const Icon(Icons.fast_forward,
              size: 36,
              color: Colors.white,
            ),
          ),
          Text(
            "$mins:$secs",
            style: const TextStyle(
                color: Colors.white,
                shadows: <Shadow>[
                  Shadow(
                      offset: Offset(0.0, 1.0),
                      blurRadius: 4.0,
                      color: Color.fromARGB(150, 0, 0, 0)
                  )
                ]
            ),
          )
        ],
      ),
    )
      ],
    );
  }


  //====Video view how to show fram========
  Widget _playView(BuildContext context){
    final controller = _controller;
    if(controller!= null && controller.value.isInitialized){
      return AspectRatio(
        aspectRatio: 16/9,
        child: VideoPlayer(controller),
      );
    } else {
      return const AspectRatio(
          aspectRatio: 16/9,
        child: Center(
          child: Text("video is loading please wait..",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white60
            ),
          ),
        )
      );
    }
  }




  //======logic for play and pause & dispose the video=======

  Duration? _duration;
  Duration? _position;
  var _progress = 0.0;
  var _onUpdateControllerTime;

  void _onControllerUpdate()async{
    if(_dispose){
      return;
    }
    _onUpdateControllerTime = 0;

    final now = DateTime.now().millisecondsSinceEpoch;

    if(_onUpdateControllerTime>now){
      return;
    }
    _onUpdateControllerTime = now+500;

    final controller = _controller;

    if(controller == null){
      //debugPrint("controller is null");
      return;
    }
    if(!controller.value.isInitialized){
      debugPrint("controller can not be init");
      return;
    }
    _duration ??= _controller?.value.duration;
    //if(_duration == null) {
    //       _duration = _controller?.value.duration;
    //     }
    var duration = _duration;
    if(duration == null) return;

    var position = await controller.position;
    _position = position;

    final playing = controller.value.isPlaying;
    if(playing) {
      //handel progress indicator
      if(_dispose) return;
      setState(() {
        _progress =  position!.inMicroseconds.ceilToDouble()/ duration.inMicroseconds.ceilToDouble();
      });
    }
    _isPlaying = playing;
  }


  //=====fuction for open the video from json=====
  _onTapVideo(int index) async{
    //final controller = VideoPlayerController.networkUrl(videoInfo[index]['videoUrl']);
    final controller = VideoPlayerController.network(Uri.parse(videoInfo[index]['videoUrl']).toString());

    final old = _controller;
    _controller = controller;
    if(old!= null){
      old.removeListener(_onControllerUpdate);
      old.pause();
    }
    setState(() {});
    controller
      ..initialize().then((_){
        old?.dispose();
        _isPlayingIndex = index;
        controller.addListener(_onControllerUpdate);
        _controller?.play();
        setState(() { });
    });
  }


  //======List of videos=================
  _listView(){
    return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
        itemCount: videoInfo.length,
        itemBuilder: (_, int index){
          return GestureDetector(
            onTap: (() => {
              debugPrint("taped"),
              _onTapVideo(index),
              setState(() {
                if(_playArea == false){
                  _playArea = true;
                }
              })
            }),
            child: _buildCard(index),
          );
        });
  }


  //======video cards in list design=========
  _buildCard(int index){
    return SizedBox(
      height: 135,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                        image: AssetImage(
                            videoInfo[index]['thumbnail']
                        ),
                        fit: BoxFit.cover
                    )
                ),
              ),
              const SizedBox(width: 10,),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(videoInfo[index]['title'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(videoInfo[index]['time'],
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
          const SizedBox(height: 20,),
          Row(
            children: [
              Container(
                width: 80,
                height: 20,
                decoration: BoxDecoration(
                    color: const Color(0xffeaeefc),
                    borderRadius: BorderRadius.circular(10)
                ),
                child: const Center(
                  child: Text('15s rest',
                    style: TextStyle(
                      color: Color(0xff839fed),
                    ),
                  ),
                ),

              ),
              Row(
                children: [
                  for(int i=0; i<70; i++)
                    i.isEven?Container(
                      width: 3,
                      height: 1,
                      decoration: BoxDecoration(
                          color: Color(0xff839fed),
                          borderRadius: BorderRadius.circular(2)
                      ),
                    ):Container(
                      width: 3,
                      height: 1,
                      color: Colors.white,
                    )
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}


