#App Design Document


##Objective
[Undecided Name] (Temporarily called Exchange) is an app that lets users exchange contact information and resumes by
putting their phones next to each other.

##Audience
I expect the majority of the user base to be college graduates or older who are
looking to network. I expect this App to be mostly used during networking events
and meet ups.

##Experience
The user is at a hack-a-thon and meets someone who is also interested in biotech.
This person happens to be the founder of a startup which is looking to hire right now.
The two hit it off, and decide to exchange contact information. They open this app,
put their phones next to each other and their profiles will be exchanged.

In this day and age we are connected to hundreds of people, and that number grows every day.
As such it's too easy to lose track of the people you've met. My hope is that this app makes
it easier for users to keep track of people they really struck a connection with.

##Technical

####External Services
Parse Framework
Bluetooth
Facebook SDK
Google SDK
LinkedIn SDK


####Screens
[Edit Profile] <-> [Exchange Screen] <-> [View Users] <-> [User Profile]
                           |
                           V
                      [Settings]

####Views / View Controllers/ Classes
Views/View Controllers - Profile View, Exchange View, Settings View, View Users View, User Profile View

####Data Models
User:
    username (default)
    password (default)
    user_id (default)
    firstName
    lastName
    email
    picture
    resume
    card

Connection:
    User_A (pointer to User)
    User_B (pointer to User)

##MVP Milestones
Week 1:
    Implement Parse Functionality (DONE)
    Integrate Facebook Login (DONE)
    Finalize Data Models (DONE)
    Complete Login View (DONE)

Week 2:
    Complete Exchange View
    Complete Settings View
    Complete Layout + Transitions

Week 3:
    Complete Profile View
    Complete View Users View
    Complete User Profile View

Week 4:
    Polish
    Ship

Weeks 5 - 8:
    Debug if necessary
    Begin new app
