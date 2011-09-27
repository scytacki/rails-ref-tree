I've been working on a rails development tool to show the references to particular partials. 
Below is an example for the show_for_student partial:

<img src="http://content.screencast.com/users/scytacki/folders/Jing/media/308f029c-b343-4064-8797-1c15ae1971b2/00000075.png"/>

basically this says:

portal/clazzes/show_for_student is referred to by 
  portal/clazzes/list_for_student which is referred to by 
    portal/students/show which is referred to by both
      home/student which is referred to by
        home/index
      portal/students/show
      

The code for generating this up here:
https://github.com/scytacki/rails-ref-tree

It doesn't support themes, but I want to add that to solve my original problem (ITSISU bin view)

It also has some hard coded paths so you need to generalize it to run it locally.
