https://medium.com/@I_am_PD/the-final-fantasy-xvi-interface-a-cabinet-of-curiosities-c0fc7fc554b1 — Paweł Durczok, *The Final Fantasy XVI interface: a Cabinet of Curiosities*, 11 settembre 2023. Estratto con strumenti/sfoglia.py.

User Interface
User Experience
Gaming
Final Fantasy Xvi
Case Study
The Final Fantasy XVI interface — a
Cabinet of Curiosities
Pawe
ł
 Durczok
Follow
10 min read
·
Sep 11, 2023
54
In the realm of digital product design video games occupy a unique
position in which the UI, in most cases, is not the primary layer of
To make 
Medium
 work, we log user data. By using 
Medium
, you agree to our
Privacy Policy
,
including cookie policy.
22/09/26, 11:57
The Final Fantasy XVI interface — a Cabinet of Curiosities | by Paweł Durczok | Medium
https://medium.com/@I_am_PD/the-final-fantasy-xvi-interface-a-cabinet-of-curiosities-c0fc7fc554b1
1
/
19
interaction with the software. But it still can have a profound impact on the
gameplay experience depending on how well-implemented and
performant it is.
While game UX and UI design is a different beast than designing a mobile
app or a SAAS solution, there are some underlying tenets for all forms of
interface designs that can be applied, compared and evaluated.
As such, I’d like to have a look at a user interface for one of the biggest games
of 2023 — Final Fantasy XVI. I’ll do that from the perspective of a product
designer but also a gamer, because ultimately, as with any digital product,
what matters to users is the end result, not how it was achieved.
Final Fantasy is a venerable game series with a long history. The first one
was released for the Nintendo Entertainment System back in 1987. The
franchise spans a few dozen games including mainline entries and spin-offs.
Most of the mainline games belong to the RPG genre, but FFXVI is more of
an action game than a traditional RPG. I mention this because it bears
relevance to the interface’s performance.
The player’s first interaction with the UI is fairly standard. The main menu is
a simple four-element list and the settings menu follows typical video game
patterns when it comes to structure and layout. The menus operate at 60fps
and are responsive and snappy. In my opinion, they miss a few features that
would enable players to customise their UX a bit, but I’ll get to those missing
features later.
To make 
Medium
 work, we log user data. By using 
Medium
, you agree to our
Privacy Policy
,
including cookie policy.
22/09/26, 11:57
The Final Fantasy XVI interface — a Cabinet of Curiosities | by Paweł Durczok | Medium
https://medium.com/@I_am_PD/the-final-fantasy-xvi-interface-a-cabinet-of-curiosities-c0fc7fc554b1
2
/
19
Settings Menu
Let’s stay for a moment with the menus and talk about the in-game ones. It’s
a fairly robust structure that houses the character’s stats and equipment,
abilities, quest log, world map and system settings. The mapping of
functions uses a standard interaction pattern with the controller’s shoulder
buttons for switching between main and sub-menu tabs and the “X” and “O”
buttons for going in and out of second-level screens. I also appreciate the
fact that switching between interaction triggers on the screens can be
accomplished either with the D-Pad in a snap-to-target manner or with the
left analog stick mimicking mouse pointer navigation. As with most PS5
games, Final Fantasy 16 does not make use of the DualSense’s touchpad or
gyroscope, which I think is a bit of a shame.
To make 
Medium
 work, we log user data. By using 
Medium
, you agree to our
Privacy Policy
,
including cookie policy.
22/09/26, 11:57
The Final Fantasy XVI interface — a Cabinet of Curiosities | by Paweł Durczok | Medium
https://medium.com/@I_am_PD/the-final-fantasy-xvi-interface-a-cabinet-of-curiosities-c0fc7fc554b1
3
/
19
All good so far. Unfortunately, this is where we encounter the main problem
of the game’s entire user experience. Something I consider a cardinal sin of
game interfaces — the developers made the interface deliberately slow.
Now, I don’t mean, of course, that they set out with the goal to make it slow,
but they’ve made several design decisions that made it so.
Issue no. 1 — Slow menu transitions and lag
The game menus feature several graphical effects that seem to have a
negative effect on performance and responsiveness. For one, there is a “fire”
animated on the bottom of the screen. An effect thematically apt, but one
that is purely aesthetic. Now I can’t be sure what the performance
implication of the effect is, though I suspect an alpha effect like that, inside
of a heavy menu structure that’s already overlaid over the game field isn’t
without impact.
The second effect is the menu’s background that features the protagonist, as
he appears in the field, with a camera pivoting to a different position around
the character on transitions to most of the menu screens (with one
exception). Visually it’s an attractive effect, but it completely (if I may use a
gaming term) tanks performance. The transitions operate at sub-30fps with a
noticeable judder and some delay. Once the animation and transition are
complete the menus then operate back at 60fps.
The exception I mentioned is the Map screen. The map is a fairly high-detail
3D model with some minor animations, markers, overlays and its own
lighting and shaders.
Now I cannot be certain, but based on its behaviour it appears that the map
isn’t loaded into memory with the rest of the menu objects and instead is
loaded on demand only when the player enters its screen. That causes a
To make 
Medium
 work, we log user data. By using 
Medium
, you agree to our
Privacy Policy
,
including cookie policy.
22/09/26, 11:57
The Final Fantasy XVI interface — a Cabinet of Curiosities | by Paweł Durczok | Medium
https://medium.com/@I_am_PD/the-final-fantasy-xvi-interface-a-cabinet-of-curiosities-c0fc7fc554b1
4
/
19
noticeable delay in the transition to that screen and disables any further
action until the map is fully loaded. That happens every time the player
switches to that screen, even if they haven’t left the menus (the previously
loaded map doesn’t seem to be stored). It means that not only this single
screen exhibits a different interaction behaviour than all the others, but it
also has a very negative impact on the overall UX of the menu system. The
question is — was such a complex map construct really necessary? Did it
improve the gaming experience, or due the associated performance issues
make it detrimental to that experience?
In-game menu transitions
Since FFXVI is a game far more focused on action and story than on RPG
elements, players won’t spend too much time rummaging through those
menus. On the one hand that means that they will need to contend with
those performance issues for a relatively small part of their game time. On
Pawe
ł
 Durczok
Guarda su
To make 
Medium
 work, we log user data. By using 
Medium
, you agree to our
Privacy Policy
,
including cookie policy.
22/09/26, 11:57
The Final Fantasy XVI interface — a Cabinet of Curiosities | by Paweł Durczok | Medium
https://medium.com/@I_am_PD/the-final-fantasy-xvi-interface-a-cabinet-of-curiosities-c0fc7fc554b1
5
/
19
the other hand, if they are not going to spend much time interacting with the
menus, is really beneficial to sacrifice performance to such a degree for
some visual flair?
I’ll leave that to decide for yourself, but I will say this — a slow menu system
stands somewhat in opposition to the idea of making the game more action-
oriented.
Issue no. 2 — HUD’s high density of information
Let’s leave the menus and step into the field.
I have to admit that personally, I find the HUD (head-up display) somewhat
busy but your mileage may vary in that respect. It’s worth noting however
that how many elements appear on the screen depends on the position in
the gameplay loop — during combat and exploration it’s quite dense, during
story moments it’s hidden. Especially during combat, the information from
the HUD needs to compete with attack and spell effects that are very
particle-heathy and fill the screen.
Open in app
Sign up
Sign in
Search
Write
To make 
Medium
 work, we log user data. By using 
Medium
, you agree to our
Privacy Policy
,
including cookie policy.
22/09/26, 11:57
The Final Fantasy XVI interface — a Cabinet of Curiosities | by Paweł Durczok | Medium
https://medium.com/@I_am_PD/the-final-fantasy-xvi-interface-a-cabinet-of-curiosities-c0fc7fc554b1
6
/
19
Combat HUD can be difficult to parse
And here’s where the inability to adjust what’s included in the HUD (one of
the absent options I’ve mentioned before) feels like a missed opportunity.
After a dozen hours of playtime, I would imagine most players would
develop enough muscle memory to make the constant display of button
mapping unnecessary. It would be good to be able to toggle those elements
on and off. Some other elements could be togglable as well — the combat
text (the numbers that show up on the screen indicating damage values),
names of abilities used or enemy health bars. FFXVI doesn’t include that
option either. Still, it’s a minor gripe and the HUD is perfectly functional.
To make 
Medium
 work, we log user data. By using 
Medium
, you agree to our
Privacy Policy
,
including cookie policy.
22/09/26, 11:57
The Final Fantasy XVI interface — a Cabinet of Curiosities | by Paweł Durczok | Medium
https://medium.com/@I_am_PD/the-final-fantasy-xvi-interface-a-cabinet-of-curiosities-c0fc7fc554b1
7
/
19
During exploration, most of the HUD could have been hidden to allow for a more immersive experience.
Issue no. 3 — It just keeps getting in the way.
Here’s where, I believe, the biggest problem of the FFXVI UI lies.
Get 
Pawe
ł
 Durczok
’s stories in your inbox
Join Medium for free to get updates from this writer.
Enter your email
Subscribe
Remember me for faster sign in
The game uses a full-screen overlay in a number of circumstances. Those
include:
To make 
Medium
 work, we log user data. By using 
Medium
, you agree to our
Privacy Policy
,
including cookie policy.
22/09/26, 11:57
The Final Fantasy XVI interface — a Cabinet of Curiosities | by Paweł Durczok | Medium
https://medium.com/@I_am_PD/the-final-fantasy-xvi-interface-a-cabinet-of-curiosities-c0fc7fc554b1
8
/
19
A new story chapter name display
End of a major combat encounter
Reaching the next experience level
The player encounters a hunt mark target (special enemy)
The underlying issue with those overlays is that for the most part, they aren’t
immediately dismissable — an animation associated with the type of overlay
needs to play out, before the “dismiss” prompt and the action become
available. A particularly egregious example is the post-battle summary
screen that shows the accumulated experience and battle points, money and
renown being added to the previous values of those stats. The animation
works like a counter, is asynchronous for all 4 elements and seems to have
easing added to it, which prolongs the tail end. Only after that animation
ends any items acquired from the fallen enemies are displayed and it
becomes possible to close the overlay. One might think it’s not a major issue,
but you’ll be seeing hundreds of those screens during the course of the
game.
And some of the overlays aren’t dismissable at all (like when encountering a
hunt mark), but are instead on a timer that needs to elapse before they fade
out. That leads to very disruptive behaviour from the UI, which clashes with
the action-oriented nature of the game. Other games of a similar type have a
more streamlined solution where they would simply display associated info
over the action/cut-scene or will delay displaying that information until after
any story-related content is delivered. A good example of such behaviour
would be the FFXVI predecessor, Final Fantasy XV, which does exactly that.
To make 
Medium
 work, we log user data. By using 
Medium
, you agree to our
Privacy Policy
,
including cookie policy.
22/09/26, 11:57
The Final Fantasy XVI interface — a Cabinet of Curiosities | by Paweł Durczok | Medium
https://medium.com/@I_am_PD/the-final-fantasy-xvi-interface-a-cabinet-of-curiosities-c0fc7fc554b1
9
/
19
Encountering a Hunt Mark
I was trying to discern whether this pattern was employed in order to mask
some data loading, but that doesn’t seem to be the case. Perhaps it’s an
unresolved remnant of some prior game design that changed during
development, but my guess would be it’s done in such a manner not to battle
for the players’ attention during story sequences.
This, however, does not account for the fact that the overlays are non-
dismissable, which is a design choice I don’t quite understand; it seems to
serve no purpose.
One additional thing worth mentioning is that some of those overlays appear
one after another, so a situation might occur where an overlay announcing
Pawe
ł
 Durczok
Guarda su
To make 
Medium
 work, we log user data. By using 
Medium
, you agree to our
Privacy Policy
,
including cookie policy.
22/09/26, 11:57
The Final Fantasy XVI interface — a Cabinet of Curiosities | by Paweł Durczok | Medium
https://medium.com/@I_am_PD/the-final-fantasy-xvi-interface-a-cabinet-of-curiosities-c0fc7fc554b1
10
/
19
an enemy’s defeat is followed by the combat summary screen, which is
followed by the “level up” screen.
Stacked Overlays
There are a few additional situations when temporary UI elements are not
dismissable, such as when you accept a quest. The quest name and
description appear on screen and the player can prioritise that quest. You
can have a limited number of prioritized quests, although to be fair the
functionality itself is a bit superfluous, considering all quests are visible both
on the map and in the quest log.
But there’s only that one interaction you can have — you either hold a button
to prioritize the quest or wait until the quest overlay disappears. Again, why
not give the players the option to dismiss the overlay sooner? This is quite a
bizarre pattern and I cannot understand its persistence. Perhaps there’s a
Pawe
ł
 Durczok
Guarda su
To make 
Medium
 work, we log user data. By using 
Medium
, you agree to our
Privacy Policy
,
including cookie policy.
22/09/26, 11:57
The Final Fantasy XVI interface — a Cabinet of Curiosities | by Paweł Durczok | Medium
https://medium.com/@I_am_PD/the-final-fantasy-xvi-interface-a-cabinet-of-curiosities-c0fc7fc554b1
11
/
19
deeper challenge the developers faced or perhaps it’s an oversight.
I will note however that the recently released Starfield handles quests in a
very similar manner, but manages to support that “prioritisation” action
without ever stopping the gameplay.
Quest Overlay
To improve the experience I think some of those overlays could have been
simply eliminated outright — the chapter name and the hunt mark ones
being prime examples.
Due to the cut-scenes considerations, it might not be feasible to eliminate
the combat summary and “level up” screens, but the ability to dismiss them
immediately could have been added. The same goes for the quest overlay.
Issue no. 4 — redundant interactions
Pawe
ł
 Durczok
Guarda su
To make 
Medium
 work, we log user data. By using 
Medium
, you agree to our
Privacy Policy
,
including cookie policy.
22/09/26, 11:57
The Final Fantasy XVI interface — a Cabinet of Curiosities | by Paweł Durczok | Medium
https://medium.com/@I_am_PD/the-final-fantasy-xvi-interface-a-cabinet-of-curiosities-c0fc7fc554b1
12
/
19
This is more of a game design choice than an issue with the interface itself,
but I still think it’s worth addressing. For a game that transitioned quite
heavily into the action genre, Final Fantasy 16 features a surprising number
of action-delaying interactions, like needing to hold a button to enter some
doors or using some switches when at the same time terrain obstacles can be
traversed by just moving in their direction. I would like to take a closer look
at two of those interactions.
Some quests require the player to acquire an item and deliver that item to an
NPC (non-playable character). When the player returns with the object, a
prompt will be displayed that requires the player to select it (most often from
a “list” of one) and then confirm that they want to give the item to the NPC.
Mind you, there’s no option to keep the item if the player wants to complete
the quest. Those items are also usually mentioned after they are delivered in
the concluding conversation between the protagonist and the NPC.
This makes the whole interaction and the UI element itself completely
redundant. This is one of the more perplexing inclusions and I’m almost
certain is a remnant from a more robust gameplay system that was left of the
cutting room floor.
To make 
Medium
 work, we log user data. By using 
Medium
, you agree to our
Privacy Policy
,
including cookie policy.
22/09/26, 11:57
The Final Fantasy XVI interface — a Cabinet of Curiosities | by Paweł Durczok | Medium
https://medium.com/@I_am_PD/the-final-fantasy-xvi-interface-a-cabinet-of-curiosities-c0fc7fc554b1
13
/
19
Item transfer
The second operation is checking on the statuses of the various systems and
activities (such as the hunts, renown progress and accessing stores). Those
usually feature a summary, a list, or a menu screen. In some circumstances,
those are accessible via an interaction with an in-game object, in which case
the associated screen will appear immediately. In other circumstances, those
are accessible by interacting with an NPC, and each of those interactions
requires the player to listen to a short voiceover and select an option from a
list. It’s a minor thing, but still an annoyance. I have to wonder why all of
those screens cannot be accessed directly either by interacting with an
object, omitting the interaction with the NPC, or directly from the in-game
menus. Or, at the very least, the list of options could appear straight away,
not after the voice-over is finished.
To make 
Medium
 work, we log user data. By using 
Medium
, you agree to our
Privacy Policy
,
including cookie policy.
22/09/26, 11:57
The Final Fantasy XVI interface — a Cabinet of Curiosities | by Paweł Durczok | Medium
https://medium.com/@I_am_PD/the-final-fantasy-xvi-interface-a-cabinet-of-curiosities-c0fc7fc554b1
14
/
19
Conclusion
For a high-budget production with such a lengthy development time from a
very experienced team, the interfaces feature some choices that seem either
unnecessary or unpolished. While by no means game-breaking, is somewhat
detrimental to the quality and enjoyment of the game.
Is it a “bad” interface? No, it is not. It’s functional, competent, provides
feedback well (even if sometimes to an excessive level), lets players access all
necessary functions, offers a decent level of context-sensitivity and, for the
most part, is well structured as far as information architecture is concerned.
Unfortunately, it’s also a rather unresponsive, unnecessarily intrusive
construct that simply isn’t very fun to use. In the context of a story-driven
action game that is a bit of a problem, with the issues of constant UI
incursion amplified. And all of those issues add up.
Granted, the main objective of a game interface isn’t to be “fun” exactly; it’s
to facilitate gameplay and FFXVI’s interface does that. I only wish it was
more refined while doing it.
User Interface
User Experience
Gaming
Final Fantasy Xvi
Case Study
Written by 
Pawe
ł
 Durczok
17 followers
·
3 following
Hi, I'm a multidisciplinary designer with over two decades of commercial
experience. Let's talk design.
Follow
To make 
Medium
 work, we log user data. By using 
Medium
, you agree to our
Privacy Policy
,
including cookie policy.
22/09/26, 11:57
The Final Fantasy XVI interface — a Cabinet of Curiosities | by Paweł Durczok | Medium
https://medium.com/@I_am_PD/the-final-fantasy-xvi-interface-a-cabinet-of-curiosities-c0fc7fc554b1
15
/
19
No responses yet
Write a response
More from 
Pawe
ł
 Durczok
What are your thoughts?
·
Nov 2, 2023
Insomniac’s Spider-Man 2 and the
death of nuance in video games
…
Insomniac’s Spider-Man 2 doesn’t seem to
respect audience’s intelligence and forgoes
…
·
May 15, 2024
The killing of Xbox
Or on how Microsoft is engaged in the worst
process of brand self-sabotage in years.
Pawe
ł
 Durczok
26
Pawe
ł
 Durczok
50
1
To make 
Medium
 work, we log user data. By using 
Medium
, you agree to our
Privacy Policy
,
including cookie policy.
22/09/26, 11:57
The Final Fantasy XVI interface — a Cabinet of Curiosities | by Paweł Durczok | Medium
https://medium.com/@I_am_PD/the-final-fantasy-xvi-interface-a-cabinet-of-curiosities-c0fc7fc554b1
16
/
19
See all from 
Pawe
ł
 Durczok
Recommended from Medium
In
by
·
Oct 19, 2023
Categorizing Errors — and how to
handle them
Error handling is one of the most important
aspects of any digital product because
…
In
by
·
Sep 1
The Era of the MAP
Why we can have nice things, but we probably
won’t.
Bootcamp
Pawe
ł
 Durczok
14
1
Bootcamp
Pawe
ł
 Durczok
To make 
Medium
 work, we log user data. By using 
Medium
, you agree to our
Privacy Policy
,
including cookie policy.
22/09/26, 11:57
The Final Fantasy XVI interface — a Cabinet of Curiosities | by Paweł Durczok | Medium
https://medium.com/@I_am_PD/the-final-fantasy-xvi-interface-a-cabinet-of-curiosities-c0fc7fc554b1
17
/
19
In
by
·
Jul 7
I’ll Instantly Know A Writer Used
ChatGPT When I See This
It’s pretty damn obvious now that I know what
to look for.
·
Sep 6
GPT-6 Astra just ended software.
And coding has NOTHING to do with that.
In
by
·
May 21
Why Everybody is Leaving Spotify
I Cancelled Spotify After 6 Years
·
May 8
How to Do Hard Things When You
Have Zero Motivation
Tricks create novelty. These five strategies
create consistency.
In
by
·
Jul 18
10 Websites Better Than Another
Hour of Doomscrolling
Here’s to the rabbit holes worth taking!
In
by
·
Apr 6
MCP is Dead
Why you should avoid using MCP in Claude
Code and what to use instead
The Daily Draft
Matt Lillywhite
30K
1260
506
Michal Malewicz
4.5K
227
36
Apple Hacks
iTalks with Max 
🍏
8.5K
422
127
Darius Foroux
18.7K
597
920
The Sunday Journal
Rafia Naseem
UX Planet
Nick Babich
To make 
Medium
 work, we log user data. By using 
Medium
, you agree to our
Privacy Policy
,
including cookie policy.
22/09/26, 11:57
The Final Fantasy XVI interface — a Cabinet of Curiosities | by Paweł Durczok | Medium
https://medium.com/@I_am_PD/the-final-fantasy-xvi-interface-a-cabinet-of-curiosities-c0fc7fc554b1
18
/
19
See more recommendations
16.5K
433
273
6.4K
348
207
To make 
Medium
 work, we log user data. By using 
Medium
, you agree to our
Privacy Policy
,
including cookie policy.
22/09/26, 11:57
The Final Fantasy XVI interface — a Cabinet of Curiosities | by Paweł Durczok | Medium
https://medium.com/@I_am_PD/the-final-fantasy-xvi-interface-a-cabinet-of-curiosities-c0fc7fc554b1
19
/
19
