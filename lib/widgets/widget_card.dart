
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:bhu/utils/constants.dart';
import 'package:bhu/utils/style.dart';
import '../models/user.dart';

class CardWidget extends StatefulWidget {
   CardWidget({super.key, required this.title, required this.subtitle, this.description, this.onTap,this.imageUrl="https://www.treasury.gov.ph/wp-content/uploads/2022/01/male-placeholder-image.jpeg"});

 final String title;
  final String subtitle;
  final String? description;
  final VoidCallback? onTap;
  final String? imageUrl;

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  UserModel? currentUser;

  @override
  void initState() {
    super.initState();
    // fetchUserDetail();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap??(){},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section with Rounded Corners
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(containerRoundCorner),
              image: widget.imageUrl!.isNotEmpty
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(widget.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Restaurant Name
                Text(
                  widget.title,
                  style: titleTextStyle(size: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),

                // Subtitle (Plant Description)
                Text(
                  widget.description!,
                  style: subTitleTextStyle(size: 14),maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Ratings, Delivery Fee, and Time
                // Row(
                //   children: [
                //     // Reward Coins
                //     Icon(
                //       Icons.monetization_on_outlined,
                //       color: primaryColor,
                //       size: 16,
                //     ),
                //     const SizedBox(width: 4),
                //     Text(
                //       widget.plant.plantCoins.toString(),
                //       style: descriptionTextStyle(
                //           size: 14,
                //           fontWeight: FontWeight.w600,
                //           color: blackColor),
                //     ),
                //     // Estimated Time
                //     SizedBox(width: defaultPadding),
                //     Icon(
                //       IconlyLight.location,
                //       color: primaryColor,
                //       size: 16,
                //     ),
                //     const SizedBox(width: 4),
                //     Text(
                //       widget.plant.gpsLocation,
                //       style: descriptionTextStyle(
                //           size: 14,
                //           fontWeight: FontWeight.w600,
                //           color: blackColor),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


  SizedBox cardWidget({String?title,String?description,String?imageUrl, VoidCallback? onPressed}) {
    return SizedBox(
      height: 125,
      child: GestureDetector(
        onTap: onPressed,
        child: Card(
          color: greyColor,
          clipBehavior: Clip.antiAlias,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          elevation: 0.1,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Container(
                  height: double.infinity,
                  width: 90,
                  margin: const EdgeInsets.only(right: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: CachedNetworkImageProvider(imageUrl!),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title!,
                          style: subTitleTextStyle(
                              fontWeight: FontWeight.w600, color: blackColor)),
                      const SizedBox(height: 2),
                      Text(
                        description!,
                        textAlign: TextAlign.left,
                        style: descriptionTextStyle(size: 12),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 4,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
