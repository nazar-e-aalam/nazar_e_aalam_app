// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:nazar_e_alam/controller/quran_settings_controller.dart';
import 'package:nazar_e_alam/helper/translator_helper.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/base/feature_items.dart';

class ListViewShimmer extends StatelessWidget {
  const ListViewShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 15,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade400,
          highlightColor: Colors.grey.shade100,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 1.0),
            child: ListTile(
              isThreeLine: true,
              leading: Container(
                height: 50,
                width: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              title: Container(height: 15, width: 90, color: Colors.white),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            height: 10,
                            width: 100,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 10),
                          Container(
                            height: 10,
                            width: 100,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Container(height: 10, width: 70, color: Colors.white),
                        const SizedBox(width: 10),
                        Container(height: 10, width: 70, color: Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton mirrors the current home layouts, not the retired dashboard.
class DashbordShimmerScreen extends StatelessWidget {
  final bool modern;
  const DashbordShimmerScreen({super.key,this.modern=false});

  @override
  Widget build(BuildContext context) {
    final t=Theme.of(context);
    final dark=t.brightness==Brightness.dark;
    final base=Color.alphaBlend(t.primaryColor.withValues(alpha:dark ? .16:.10),t.cardColor);
    final highlight=Color.alphaBlend(t.primaryColor.withValues(alpha:dark ? .30:.03),t.cardColor);
    Widget bone(double height,{double? width,double radius=8})=>Container(height:height,width:width,decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(radius)));
    Widget panel(Widget child,{double radius=24})=>Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:t.cardColor,borderRadius:BorderRadius.circular(radius),border:Border.all(color:t.primaryColor.withValues(alpha:.12))),child:child);
    Widget pulse(Widget child)=>Shimmer.fromColors(baseColor:base,highlightColor:highlight,child:child);
    Widget lines()=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[bone(15,width:100),const SizedBox(height:9),bone(11,width:65)]);
    return SingleChildScrollView(physics:const NeverScrollableScrollPhysics(),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      if(modern) Container(padding:EdgeInsets.fromLTRB(20,MediaQuery.of(context).padding.top+14,20,26),decoration:BoxDecoration(gradient:LinearGradient(colors:[dark?t.cardColor:t.primaryColor,dark?t.scaffoldBackgroundColor:const Color(0xffC94B20)]),borderRadius:const BorderRadius.vertical(bottom:Radius.circular(30))),child:Shimmer.fromColors(baseColor:Colors.white24,highlightColor:Colors.white54,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Expanded(child:Align(alignment:AlignmentDirectional.centerStart,child:bone(25,width:170))),bone(40,width:40,radius:20),const SizedBox(width:10),bone(40,width:40,radius:20)]),const SizedBox(height:10),bone(14,width:145)]))),
      Padding(padding:EdgeInsets.fromLTRB(16,modern?16:12,16,modern?110:24),child:Column(children:[
        if(modern)...[
          Container(height:140,padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:dark?t.cardColor:t.primaryColor,borderRadius:BorderRadius.circular(24)),child:Shimmer.fromColors(baseColor:Colors.white24,highlightColor:Colors.white54,child:Row(children:[SizedBox(width:92,child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[bone(12,width:70),const SizedBox(height:8),bone(24,width:80),const SizedBox(height:8),bone(20,width:65)])),const SizedBox(width:12),for(int i=0;i<3;i++)Expanded(child:Padding(padding:const EdgeInsets.symmetric(horizontal:3),child:bone(108,radius:16)))]))),
          const SizedBox(height:5),panel(pulse(Row(children:[bone(86,width:86,radius:43),const SizedBox(width:16),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[bone(16,width:140),const SizedBox(height:8),bone(12),const SizedBox(height:12),bone(8),const SizedBox(height:12),bone(38,radius:12)]))]))),const SizedBox(height:5),
        ]else...[panel(pulse(Row(children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[bone(22,width:140),const SizedBox(height:12),bone(13,width:110),const SizedBox(height:18),bone(38,width:125)])),bone(120,width:100,radius:20)])),radius:18),const SizedBox(height:8),for(int i=0;i<3;i++)Padding(padding:const EdgeInsets.only(bottom:12),child:Row(children:[for(int j=0;j<2;j++)Expanded(child:Padding(padding:EdgeInsetsDirectional.only(end:j==0?6:0,start:j==1?6:0),child:panel(pulse(Row(children:[bone(34,width:34,radius:17),const SizedBox(width:8),Expanded(child:lines())])),radius:16)))]))],
        GridView.builder(shrinkWrap:true,primary:false,padding:EdgeInsets.zero,physics:const NeverScrollableScrollPhysics(),itemCount:FeatureItems.all().length,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:3,crossAxisSpacing:3,mainAxisSpacing:3,mainAxisExtent:116),itemBuilder:(_,i)=>panel(pulse(Column(mainAxisAlignment:MainAxisAlignment.center,children:[bone(50,width:50,radius:25),const SizedBox(height:8),bone(12,width:64)])),radius:modern?22:18)),
      ]))
    ]));
  }
}

class NearbyMosqueShimmerScreen extends StatelessWidget {
  const NearbyMosqueShimmerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade400,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.PADDING_SIZE_SMALL,
            vertical: Dimensions.PADDING_SIZE_SMALL,
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 15,
                  width: double.infinity,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_GRID_SMALL),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 15,
                  width: double.infinity,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_GRID_SMALL),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(height: 15, width: 200, color: Colors.white),
              ),
              const SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
              // dropdown ==>
              Card(
                color: Colors.transparent,
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL,
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 13.0),
                              child: Container(
                                height: 20,
                                width: 60,
                                color: Colors.white,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(right: 13.0),
                              child: Icon(
                                Icons.arrow_drop_down_sharp,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),

              // list view ===>
              ListView.builder(
                primary: false,
                shrinkWrap: true,
                itemCount: 10,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5.0,
                      horizontal: 4.0,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white, // Set the border color
                          // Set the border width
                        ),
                        borderRadius: BorderRadius.circular(
                          4,
                        ), // Optional: Set the border radius
                      ),
                      child: ListTile(
                        // tileColor: Colors.transparent,
                        contentPadding: const EdgeInsetsDirectional.symmetric(
                          horizontal: Dimensions.PADDING_SIZE_DEFAULT,
                        ),
                        trailing: Container(
                          height: 35,
                          width: 35,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),

                        title: Container(
                          height: 15,
                          width: 90,
                          color: Colors.white,
                        ),
                        subtitle: Row(
                          children: [
                            Container(
                              height: 13,
                              width: 190,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuiblaeShimmerScreen extends StatelessWidget {
  const QuiblaeShimmerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Static direction values in degrees
    const double staticDirection = 90.0; // Compass rotation angle
    const double staticQiblah = 220.0; // Qiblah angle

    return Shimmer.fromColors(
      baseColor: Colors.grey.shade400,
      highlightColor: Colors.grey.shade100,
      child: SizedBox(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 500),
                      turns: (staticDirection * (pi / 180) * -1) / (2 * pi),
                      child: Image.asset(
                        Images.Compass,
                        height: 330,
                        fit: BoxFit.fill,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 1000),
                      turns: (staticQiblah * (pi / 180) * -1) / (2 * pi),
                      child: Image.asset(
                        Images.Compass_Needle,
                        height: 400,
                        color: Colors.white,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: 10.0,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).hintColor.withOpacity(0.05),
                      Theme.of(context).hintColor.withOpacity(0.10),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(height: 15, width: 50, color: Colors.white),
                    const SizedBox(height: 2.0),
                    Container(height: 15, width: 90, color: Colors.white),
                  ],
                ),
              ),
              const SizedBox(height: 40.0),
            ],
          ),
        ),
      ),
    );
  }
}

class DonationTypeShimmer extends StatelessWidget {
  const DonationTypeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 15,
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.PADDING_SIZE_SMALL,
      ),
      itemBuilder: (BuildContext context, int index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade400,
          highlightColor: Colors.grey.shade100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Card(
              color: Colors.transparent,
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                contentPadding: const EdgeInsetsDirectional.only(
                  start: Dimensions.PADDING_SIZE_EXTRA_SMALL,
                  end: Dimensions.PADDING_SIZE_SMALL,
                ),

                leading: Container(
                  height: 40,
                  width: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SvgPicture.asset(
                        Images.Icon_Star,
                        height: 50,
                        fit: BoxFit.fill,
                        color: Colors.white,
                      ),
                      Text(
                        "$index",
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.FONT_SIZE_SMALL,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                title: Container(height: 15, width: 20, color: Colors.white),
                trailing: const Text("         "),
                // title:  Text(
                //   "Donation Type",
                //   style: robotoMedium.copyWith(
                //     fontSize: Dimensions.FONT_SIZE_SMALL,
                //     color: Colors.white,
                //   ),
                // ) ,
              ),
            ),
          ),
        );
      },
    );
  }
}

class WallpaperListTypeShimmer extends StatelessWidget {
  const WallpaperListTypeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: 8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 12,
        childAspectRatio: 0.57,
      ),
      itemBuilder: (context, index) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                height: 14,
                width: double.infinity,
                color: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }
}

class WallpaperDetailsTypeShimmer extends StatelessWidget {
  const WallpaperDetailsTypeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade400,
        highlightColor: Colors.grey.shade100,
        child: GridView.builder(
          itemCount: 6,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            mainAxisExtent: 326,
          ),
          itemBuilder: (context, index) {
            return ListView(
              children: [
                Container(
                  height: 280,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      width: 1,
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                Container(
                  height: 15,
                  width: Get.width * 0.5,
                  color: Colors.white,
                ),
                const SizedBox(height: 5.0),
                Padding(
                  padding: const EdgeInsets.only(right: 100.0),
                  child: Container(
                    height: 10,
                    width: Get.width * 0.2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5.0),
              ],
            );
          },
        ),
      ),
    );
  }
}

class QuranListShimmer extends StatelessWidget {
  const QuranListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 15,
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.PADDING_SIZE_SMALL,
      ),
      itemBuilder: (BuildContext context, int index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade400,
          highlightColor: Colors.grey.shade100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Card(
              color: Colors.transparent,
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                contentPadding: const EdgeInsetsDirectional.only(
                  start: Dimensions.PADDING_SIZE_EXTRA_SMALL,
                  end: Dimensions.PADDING_SIZE_SMALL,
                ),
                leading: Container(
                  height: 40,
                  width: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SvgPicture.asset(
                        Images.Icon_Star,
                        height: 50,
                        fit: BoxFit.fill,
                        color: Colors.white,
                      ),
                      Text(
                        "$index",
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.FONT_SIZE_SMALL,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                title: Container(height: 15, width: 90, color: Colors.white),
                subtitle: Row(
                  children: [
                    Container(height: 13, width: 60, color: Colors.white),
                  ],
                ),
                trailing: Container(
                  height: 30,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AyahTranslationShimmer extends StatelessWidget {
  const AyahTranslationShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 15,
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.PADDING_SIZE_SMALL,
      ),
      itemBuilder: (BuildContext context, int index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade400,
          highlightColor: Colors.grey.shade100,
          child: Card(
            clipBehavior: Clip.antiAlias,
            color: Colors.transparent,

            // shadowColor:Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const SizedBox(
                    height: Dimensions.PADDING_SIZE_EXTRA_GRID_SMALL,
                  ),
                  // arabic ayah ==>
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      height: 25,
                      width: 170,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                  // translation aysh ===>
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: 15,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: Dimensions.PADDING_SIZE_EXTRA_GRID_SMALL,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: 15,
                      width: 100,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // end ayah image
                      Container(
                        height: 40,
                        width: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SvgPicture.asset(
                              Images.Icon_Star,
                              height: 40,
                              fit: BoxFit.fill,
                              color: Colors.white,
                            ),
                            Text(
                              "$index",
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.FONT_SIZE_SMALL,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // bookmark & Share button
                      Row(
                        children: [
                          // Share Ayah
                          IconButton(
                            onPressed: () {},
                            icon: SvgPicture.asset(
                              Images.Icon_Share,
                              height: 28,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ArabicTranslationShimmer extends StatelessWidget {
  const ArabicTranslationShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL,
          ),
          child: SizedBox(
            width: double.infinity,
            child: Card(
              clipBehavior: Clip.antiAlias,
              color: Theme.of(context).cardColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(
                  Images.Bismillah,
                  height: 50,
                  fit: BoxFit.fitHeight,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        ),
        ListView.builder(
          itemCount: 15,
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.PADDING_SIZE_SMALL,
          ),
          itemBuilder: (BuildContext context, int index) {
            return Shimmer.fromColors(
              baseColor: Colors.grey.shade400,
              highlightColor: Colors.grey.shade100,
              child: Column(
                children: [
                  // ayah content and frame ==>
                  Container(
                    padding:
                        Get.find<SettingsController>().arabicFontSize.value <=
                            25
                        ? const EdgeInsets.all(
                            Dimensions.PADDING_SIZE_SMALL + 5,
                          )
                        : const EdgeInsets.all(
                            Dimensions.PADDING_SIZE_SMALL + 20,
                          ),
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      image: DecorationImage(
                        image: AssetImage(Images.Quran_Frame),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Obx(
                      () => Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          children: [
                            // arabic ayah text ==>
                            SelectableText(
                              "بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ (١)  ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَـٰلَمِينَ (٢)  ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ (٣)  مَـٰلِكِ يَوْمِ ٱلدِّينِ (٤)  إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ (٥)  ٱهْدِنَا ٱلصِّرَٰطَ ٱلْمُسْتَقِيمَ (٦)  صِرَٰطَ ٱلَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ ٱلْمَغْضُوبِ عَلَيْهِمْ وَلَا ٱلضَّآلِّينَ (٧)",
                              // textDirection: TextDirection.rtl,
                              textAlign: TextAlign.center,
                              style: Get.find<SettingsController>()
                                  .selectedArabicFont
                                  .copyWith(
                                    fontSize: Get.find<SettingsController>()
                                        .arabicFontSize
                                        .value,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium!.color,
                                  ),
                            ),
                            const SizedBox(
                              height: Dimensions.PADDING_SIZE_DEFAULT,
                            ),

                            // page number
                            SelectableText(
                              "$index",
                              // textDirection: TextDirection.rtl,
                              textAlign: TextAlign.center,
                              style: robotoMedium.copyWith(
                                color: Get.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Divider(),
                  const SizedBox(height: 5),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class DhikirShimmer extends StatelessWidget {
  const DhikirShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 15,
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.PADDING_SIZE_SMALL,
      ),
      itemBuilder: (BuildContext context, int index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade400,
          highlightColor: Colors.grey.shade100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Card(
              clipBehavior: Clip.antiAlias,
              color: Colors.transparent,
              child: ListTile(
                contentPadding: const EdgeInsetsDirectional.symmetric(
                  horizontal: Dimensions.PADDING_SIZE_DEFAULT,
                ),

                // Dhikr Title English---->
                title: Row(
                  children: [
                    Container(height: 20, width: 120, color: Colors.white),
                  ],
                ),
                trailing: Container(
                  height: 25,
                  width: 100,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class DhikirCountShimmer extends StatelessWidget {
  const DhikirCountShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade400,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: [
          // Arabic and English Dhikr name and discription section---->
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: Dimensions.PADDING_SIZE_SMALL,
                        ),
                        child: SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: SvgPicture.asset(
                            Images.Bismillah,
                            height: 60,
                            fit: BoxFit.fitHeight,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Divider(color: Colors.white),
                      Text(
                        "arabic".tr,
                        textAlign: TextAlign.start,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(height: 25, width: 120, color: Colors.white),
                      const Divider(color: Colors.white),
                      Text(
                        "english".tr,
                        textAlign: TextAlign.justify,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(height: 20, width: 160, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white),

          // Count Section----->
          Expanded(
            child: Column(
              children: [
                Text(
                  "count".tr,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  translateText('0'),
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE + 30,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),

          // Add and reset button section ----->
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(child: SizedBox()),

              Expanded(
                child: GestureDetector(
                  onTap: () async {},
                  child: SvgPicture.asset(
                    Images.Icon_Tap_Screen,
                    height: 100,
                    width: 100,
                    fit: BoxFit.fill,
                    color: Colors.white,
                  ),
                ),
              ),

              // // Reset buttion here---->
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Show the alert dialog
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10, bottom: 10),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: SvgPicture.asset(
                        Images.Icon_Reset,
                        height: 35,
                        width: 35,
                        fit: BoxFit.fill,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_LARGE),
        ],
      ),
    );
  }
}

class DhuaShimmer extends StatelessWidget {
  const DhuaShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 15,
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.PADDING_SIZE_SMALL,
      ),
      itemBuilder: (BuildContext context, int index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade400,
          highlightColor: Colors.grey.shade100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Card(
              clipBehavior: Clip.antiAlias,
              color: Colors.transparent,
              child: ListTile(
                contentPadding: const EdgeInsetsDirectional.symmetric(
                  horizontal: Dimensions.PADDING_SIZE_DEFAULT,
                ),
                title: Row(
                  children: [
                    Container(height: 15, width: 200, color: Colors.white),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(
                    top: Dimensions.PADDING_SIZE_SMALL,
                  ),
                  child: Row(
                    children: [
                      Container(height: 20, width: 100, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class DhuaDetailsShimmer extends StatelessWidget {
  const DhuaDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade400,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.PADDING_SIZE_DEFAULT,
          vertical: Dimensions.FONT_SIZE_SMALL,
        ),
        child: ListView(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // bismillah image ===>
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: SvgPicture.asset(
                    Images.Bismillah,
                    height: 50,
                    fit: BoxFit.fitHeight,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                const Divider(color: Colors.white),

                // arabic string ===>
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    height: 25,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(height: 25, width: 200, color: Colors.white),
                ),
                const SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                // english string ===>
                Container(
                  height: 15,
                  width: double.infinity,
                  color: Colors.white,
                ),
                const SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                Container(
                  height: 15,
                  width: double.infinity,
                  color: Colors.white,
                ),
                const SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(height: 15, width: 200, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HadisBookShimmer extends StatelessWidget {
  const HadisBookShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 15,
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.PADDING_SIZE_SMALL,
      ),
      itemBuilder: (BuildContext context, int index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade400,
          highlightColor: Colors.grey.shade100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Card(
              clipBehavior: Clip.antiAlias,
              color: Colors.transparent,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL + 2,
                  vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL,
                ),
                horizontalTitleGap: 0,
                leading: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    height: 50,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                title: Container(height: 20, width: 90, color: Colors.white),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    Container(height: 15, width: 150, color: Colors.white),
                    const SizedBox(height: 5),
                    Container(height: 10, width: 70, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class HadisChapterShimmer extends StatelessWidget {
  const HadisChapterShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 15,
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.PADDING_SIZE_SMALL,
      ),
      itemBuilder: (BuildContext context, int index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade400,
          highlightColor: Colors.grey.shade100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Card(
              clipBehavior: Clip.antiAlias,
              color: Colors.transparent,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL,
                ),
                horizontalTitleGap: 0,
                leading: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SvgPicture.asset(
                          Images.Icon_Star,
                          height: 50,
                          fit: BoxFit.fill,
                          color: Colors.white,
                        ),
                        Text(
                          "$index",
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.FONT_SIZE_SMALL,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                title: Container(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  height: 20,
                  width: 90,
                  color: Colors.white,
                ),
                subtitle: Row(
                  children: [
                    Container(height: 15, width: 120, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AllahNameShimmer extends StatelessWidget {
  const AllahNameShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 15,
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.PADDING_SIZE_SMALL,
      ),
      itemBuilder: (BuildContext context, int index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade400,
          highlightColor: Colors.grey.shade100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Card(
              clipBehavior: Clip.antiAlias,
              color: Colors.transparent,
              child: ListTile(
                contentPadding: const EdgeInsetsDirectional.only(
                  start: Dimensions.PADDING_SIZE_EXTRA_SMALL,
                  end: Dimensions.PADDING_SIZE_SMALL,
                ),
                horizontalTitleGap: 5,
                leading: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SvgPicture.asset(
                          Images.Icon_Star,
                          height: 50,
                          fit: BoxFit.fill,
                          color: Colors.white,
                        ),
                        Text(
                          "$index",
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.FONT_SIZE_SMALL,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Container(height: 20, width: 120, color: Colors.white),
                  ],
                ),
                trailing: Container(
                  height: 30,
                  width: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AllahNameDetailsShimmer extends StatelessWidget {
  const AllahNameDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade400,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.PADDING_SIZE_DEFAULT,
            vertical: Dimensions.PADDING_SIZE_DEFAULT,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // bismillah image
              SizedBox(
                height: 50,
                width: double.infinity,
                child: SvgPicture.asset(
                  Images.Bismillah,
                  height: 50,
                  fit: BoxFit.fitHeight,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              const Divider(color: Colors.white),

              // english name ==>
              Center(
                child: Container(height: 15, width: 200, color: Colors.white),
              ),
              const Divider(color: Colors.white),
              const SizedBox(height: 30),

              // arabic name ==>
              Center(
                child: Container(height: 25, width: 100, color: Colors.white),
              ),
              const SizedBox(height: 30),
              const Divider(color: Colors.white),

              // name title ===>
              Center(
                child: Container(height: 20, width: 200, color: Colors.white),
              ),
              const Divider(color: Colors.white),

              // meaning ===>
              Text(
                "meaning".tr,
                textAlign: TextAlign.start,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.FONT_SIZE_OVER_LARGE,
                ),
              ),
              const SizedBox(height: 10),

              // name meaning ===>
              Container(
                height: 15,
                width: double.infinity,
                color: Colors.white,
              ),
              const SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
              Container(
                height: 15,
                width: double.infinity,
                color: Colors.white,
              ),
              const SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
              Container(height: 15, width: 150, color: Colors.white),

              const Divider(color: Colors.white),

              // meaning ===>
              Text(
                "benefits".tr,
                textAlign: TextAlign.start,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.FONT_SIZE_OVER_LARGE,
                ),
              ),
              const SizedBox(height: 10),

              // name meaning ===>
              Container(
                height: 15,
                width: double.infinity,
                color: Colors.white,
              ),
              const SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
              Container(
                height: 15,
                width: double.infinity,
                color: Colors.white,
              ),
              const SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
              Container(height: 15, width: 150, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class HaramCodeShimmer extends StatelessWidget {
  const HaramCodeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.PADDING_SIZE_DEFAULT,
        vertical: Dimensions.PADDING_SIZE_SMALL,
      ),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:
              MediaQuery.of(context).orientation == Orientation.portrait
              ? 3
              : 5,
          crossAxisSpacing: 5.0,
          mainAxisSpacing: 5.0,
        ),
        itemCount: 15,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade400,
            highlightColor: Colors.grey.shade100,
            child: GestureDetector(
              onTap: () {},
              child: Card(
                clipBehavior: Clip.antiAlias,
                color: Colors.transparent,
                elevation: 2.0,
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                  child: Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 5),
                        Container(
                          height: 15,
                          color: Colors.white,
                          child: Text(
                            "E10gttgg",
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.FONT_SIZE_DEFAULT,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Center(
                          child: Container(
                            height: 15,
                            color: Colors.white,
                            child: Text(
                              "E10gttggffffg1",
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.FONT_SIZE_DEFAULT,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          height: 15,
                          color: Colors.white,
                          child: Text(
                            "E10gttggff",
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.FONT_SIZE_DEFAULT,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ChandShimmer extends StatelessWidget {
  const ChandShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade400,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            Container(
              height: 80,
              width: 80,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 16),
            Container(height: 20, width: 150, color: Colors.white),
            const SizedBox(height: 8),
            Container(height: 15, width: 200, color: Colors.white),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 12, width: 90, color: Colors.white),
                        const SizedBox(height: 6),
                        Container(height: 16, width: 120, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 16,
                    width: 16,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(height: 14, width: 100, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
