import 'package:flutter/material.dart';
import 'models.dart';
import 'MenuDrawer.dart';
import 'bike_detail_view.dart';


// information/instructions: Renders the bike list from the 
// BikeListModel object's data.
// @params: BikeListModel
// @return: 
// bugs: no known bugs
// TODO: 
// 1. This maybe should be stateless, I'm not sure. 
// If we include sort filters, it may be the case that
// stateful is what we want, so that the list will render differently
// based on which filters are used.

class BikeListView extends StatefulWidget {
  final BikeListModel bikeList;
  const BikeListView({ Key? key, 
    required this.bikeList }) : super(key: key);

  @override
  State<BikeListView> createState() => _BikeListViewState();
}

// This is the state object that is called by BikeListView().
class _BikeListViewState extends State<BikeListView> {
  String buttonToolTipText = "add a bike";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bikes Nearby'),
      ),
      endDrawer: const MenuDrawer(),
      body: BikeListBody(bikeList: mockList),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your onPressed code here!
          Navigator.pushNamed(
              context, '/add-bike',
            );       
            debugPrint('add bike clicked');   
        },
        tooltip: buttonToolTipText,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}


// information/instructions: This Widget is rendered within the 
//BikeListView widget.  
// @params: BikeListModel
// @return: rendering of bikeList
// bugs: no known bugs
// TODO: 
// 1. Consider whether this should be it's own class, or
// if it can just be part of the BikeListView. I think we can 
// can leave that decision until we see how complex bikeListView
// needs to be. If it turns out they are both fairly small classes,
// it might make more sense to merge them into one.
class BikeListBody extends StatelessWidget {
  final BikeListModel bikeList;
  const BikeListBody({ Key? key,
     required this.bikeList }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return  SizedBox(
      child: ListView.builder(
        itemCount: bikeList.getLength(),
        itemBuilder: (context,i) {
          return BikeListTile(bikeData: bikeList.bikes[i]);
        }
      )
    );
  }
}


// displays summary vew of journal entry
// takes JournalEntry object from models as param.

// information/instructions: Displays info for one bike for the
// BikeListView(). Each tile is clickable and should navigate to
// the BikeDetailView for that particular bike.
// @params: Bike()
// @return: View of bike basic info, including photo, name, distance,
// rating
// bugs: no known bugs
// TODO: 
// 1. Distance: will need to calculate the distance from the bike's 
//  location to the user's current location.
// 2. Clean up the style.
// 3. 
class BikeListTile extends StatelessWidget {
  final Bike bikeData;
  const BikeListTile({ Key? key, 
    required this.bikeData,
     }) : super(key: key);

  final distanceFromUser = 1;
 
  @override
  Widget build(BuildContext context) {
    double bikeRating = bikeData.getRating();
    String? bikeNameString = bikeData.getName()!;
    String distanceString = 'distance:' + distanceFromUser.toString();
    String bikeImageUrl = bikeData.getImageUrl();
    return 
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => 
              BikeDetailView(bikeData: bikeData) )
          );
        },
        child: ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row( // top row of an individual bike listing
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(bikeNameString),
                  Text(distanceString)
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(bikeImageUrl,
                    width: 100,
                    fit:BoxFit.cover  
                  ), 
                  RatingStars(rating: bikeRating)   
                ],
              ),
              const Divider(
                height: 20,
                thickness: 5,
                endIndent: 0,
                color: Colors.grey,
          ),
            ]
        )
      )
    );
  }
}

// information/instructions: Renders a row with the string "rating: "
// followed by 5 yellow stars. Stars will be filled in according to 
// the rating parameter.  
// @params: double rating
// @return: star rating
// bugs: no known bugs
// TODO: 
// 1. Right now it only works when the rating provided is an integer,
// even though we are using the double data type. In the planning doc,
// rating is specified as a float, but dart only has int and double (at
// least if I understood what I read correctly.)
// 2. 
// 3. 
class RatingStars extends StatelessWidget {
  final double rating;
  final numStarsPossible = 5;  
  const RatingStars({Key? key, this.rating = 0})
      : super(key: key);  
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('rating:'),
        Row(//row of stars
          mainAxisSize: MainAxisSize.min,
          children: List.generate(numStarsPossible, (index) {
            return Icon(
              index < rating ? Icons.star : Icons.star_border,
              color:const Color(0xFFFDCC0D)
            );
          }),
        )
      ],
    ); 
      
  }
}