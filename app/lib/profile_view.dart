import 'package:flutter/material.dart';
import 'package:the_bike_kollective/bike_list_view.dart';
import 'package:the_bike_kollective/return-bike-form.dart';
import 'package:the_bike_kollective/get-photo.dart';
import 'package:the_bike_kollective/global_values.dart';
import 'models.dart';
import 'requests.dart';
import 'global_values.dart';
import 'style.dart';


// information/instructions: ProfileView is a template that will
// conditionally render profileViewA or ProfileViewB. If property 
// hasABikeCheckedOut is true, ProfileViewA is rendered, otherwise
// ProfileViewB is rendered.
// @params: required User object with a property HasABikeCheckedOut.
// @return: nothing returned
// bugs: no known bugs
class ProfileView extends StatefulWidget {
  const ProfileView({ Key? key }) 
      : super(key: key);

  static const routeName = '/profile-view';
  @override
  State<ProfileView> createState() => _ProfileViewState();
}

// This is the state class that is used by ProfileViewState.
class _ProfileViewState extends State<ProfileView> {
  
  @override
  void initState() {
    super.initState();
  }
  Future<User> user = 
    getUser(getCurrentUserIdentifier() );
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('The Bike Kollective')
        ),
      //backgroundColor: appStyle['backGroundColor'],
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                "assets/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child:  Center(
          
          child: FutureBuilder<User>(
            future: user,
            builder: (context, AsyncSnapshot<User> snapshot) {
              if(snapshot.hasData) {
                User userData = snapshot.data!;
                String checkedOutBike = userData.getCheckedOutBike();
                return (checkedOutBike == "-1") ? 
                  ProfileViewB(user: userData) : 
                  ProfileViewA(
                    bikeId: userData.getCheckedOutBike(),
                    userGivenName: userData.getGivenName(),
                  );
              } else {
                return const CircularProgressIndicator();
              }
            }
          )
        )
      )
    );
  }
}


// information/instructions: Both ProfileViewA and B are rendered by 
// ProfileView, depending on whether the user has a bike checked out.
// ProfileViewA is shown if the user DOES have a bike checked out.
// @params: required User object with a property HasABikeCheckedOut.
// @return: nothing returned
// bugs: no known bugs
class ProfileViewA extends StatelessWidget {
  final String bikeId;
  final String userGivenName;
  
  ProfileViewA({ Key? key, 
    required this.bikeId,
    required this.userGivenName })
    : super(key: key);
  late Future<Bike> bikeData = getBike(bikeId);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Bike>(
      future: bikeData,
      builder: (context, AsyncSnapshot<Bike> snapshot) {
        if (snapshot.hasData) {
            Bike checkedOutBike = snapshot.data!;
            String bikeName = checkedOutBike.getName();
            String bikeId = checkedOutBike.getId();
            int bikeCombo = checkedOutBike.getLockCombination();
            return 
            Container(
              // height:400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,  
                mainAxisAlignment: MainAxisAlignment.start,
                children:  [
                  Padding(
                    padding: const EdgeInsets.all(3),
                    child: Text('Welcome, $userGivenName!', 
                      style: pagesStyle['defaultText'],
                      textAlign: TextAlign.center
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(3),
                    child: Text('You currently have a bike checked out.', 
                      style: pagesStyle['defaultText'],
                      textAlign: TextAlign.center
                    ),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.all(3),
                    child: Text('Bike Name: "$bikeName"', 
                      style: pagesStyle['defaultText'],
                      textAlign: TextAlign.center
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(3),
                    child: Text('Bike ID: $bikeId', 
                      style: pagesStyle['defaultText'],
                      textAlign: TextAlign.center
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(3),
                    child: Text('Lock Combination: $bikeCombo', 
                      style: pagesStyle['defaultText'],
                      textAlign: TextAlign.center
                    ),
                  ),
                  const SizedBox(height: 15),
                  CheckedOutBikeRow(checkedOutBike: checkedOutBike),
                  const SizedBox(height: 15),
                  OutlinedButton(
                    
                    style:buttonStyle['main'],
                    onPressed: () {
                      Navigator.pushNamed(context, ReturnBikeForm.routeName,);
                      debugPrint('Return Bike button clicked');
                    },
                    child: const Text('Return Bike'),
                  ),
                ],
              )
          );
               
          } else {
            return const CircularProgressIndicator();
          }
      }
    );
  }
}

// information/instructions: Both ProfileViewA and B are rendered by 
// ProfileView, depending on whether the user has a bike checked out.
// @params: required User object with a property HasABikeCheckedOut.
// @return: nothing returned
// bugs: no known bugs
class ProfileViewB extends StatelessWidget {
  final User user;
  const ProfileViewB({ Key? key, required this.user }) 
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    String currentUserGivenName = user.getGivenName();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Welcome Message  
        Padding(
          padding: const EdgeInsets.all(3),
          child: Text('Welcome, $currentUserGivenName!', 
            style: pagesStyle['welcomeMessage'],
            textAlign: TextAlign.center
          )
        ),

        // Find a Bike Button
        SizedBox(
          child: OutlinedButton(
            style: buttonStyle['main'],
            onPressed: () {
              debugPrint('Find a Bike button clicked');
              Navigator.pushNamed(
                context, BikeListView.routeName,
              );           
            },
            child: const Text('Find a Bike'),
          ),
          width: 200
        ),

        // Add a Bike Button
        SizedBox(
          child: OutlinedButton(
            style: buttonStyle['main'],
            onPressed: () {
              Navigator.pushNamed(
                context, GetPhoto.routeName,
              );       
              debugPrint('add bike clicked');   
            },
            child: const Text('Add a Bike'),
          ),
          width:200
        )

      ],
    );  
  }
}


// information/instructions: Rendered by profileViewA, when the 
// user has a bike that is checked out. 
// @params: Bike
// @return: Renders row with info about the bike that is
// checked out
// bugs: no known bugs
class CheckedOutBikeRow extends StatelessWidget {
  final Bike checkedOutBike;
  const CheckedOutBikeRow({ Key? key,
     required this.checkedOutBike}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String imageUrl = checkedOutBike.getImageUrl();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.network(imageUrl,
          width: 200,
          fit:BoxFit.cover  
        ),
        Text('Enjoy your ride!', style: pagesStyle['defaultText'] ),
        const SizedBox(width: 2)
      ],      
    );
  }
}