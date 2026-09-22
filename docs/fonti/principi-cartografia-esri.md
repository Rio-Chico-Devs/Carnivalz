https://www.esri.com/arcgis-blog/products/arcgis-pro/mapping/primary-design-principles-for-cartography — Aileen Buckley (Esri), *Primary Design Principles for Cartography*, estratto da *Map Use*, nona edizione. Estratto con strumenti/sfoglia.py.

Note: This is an excerpt from 
, and it
updates an older blog post, 
.
Cartographers rely on many design principles when
compiling maps and constructing page layouts, whether on
screen or on paper. Five of these design principles form a
system for seeing and understanding the relative
importance of the content in the map and on the page.
Without these primary principles, map-based
communication is bound to fail.
Legibility and visual contrast provide the basis for seeing
the contents within the map. Figure-ground and visual
hierarchy lead the map reader to determine the importance
of things and ultimately find patterns. And proportion lends
aesthetic appeal to the map and its layout.
These five principles are essential in cartography. It’s worth
noting that they are not applied in isolation but act
complementarily. Together, they help cartographers create
maps that successfully communicate geographic
information.
1. Legibility
Legibility is the ability to be seen and understood. Many
people strive to make their map contents and page
elements easily seen, but it is also important that they are
understood. Readers effortlessly see and understand
symbols that are appropriately sized and familiar. Geometric
symbols are easier to read at smaller sizes, while more
complex symbols require more space to be legible.
Mapping
ArcGIS Pro
Apr 24, 2026
Primary Design Principles for Cartography
By 
ArcGIS Blog
Aileen Buckley
Map Use, ninth edition
Design principles for
cartography
22/09/26, 10:57
Primary Design Principles for Cartography
https://www.esri.com/arcgis-blog/products/arcgis-pro/mapping/primary-design-principles-for-cartography
1
/
10
Appropriately sized text and fonts with open space within and between letters can be
more easily read. Familiar symbols and those that look like what they stand for can be
more easily understood.
Symbols and text that are too small are illegible.
Complex text and symbols need to be larger to be seen and understood (C), and
unfamiliar symbols can confuse map readers and require the use of a legend (C).
2. Visual Contrast
Visual contrast relates to how map features and page
elements contrast with each other and their background. To
understand this principle at work, consider your inability to
see well in a dark environment. Because not much reflected
light reaches your eyes, there is little visual contrast between
22/09/26, 10:57
Primary Design Principles for Cartography
https://www.esri.com/arcgis-blog/products/arcgis-pro/mapping/primary-design-principles-for-cartography
2
/
10
the objects in your field of view, and you can’t easily
distinguish one object from one another or from its
surroundings. Increase the illumination and you’re better
able to distinguish between features and their background.
The concept of visual contrast also applies in cartography.
Good visual contrast can result in a crisp, clean, clear-
looking map. Visual contrast helps to emphasize differences,
highlight important features, and improve readability. It can
be achieved by varying symbol and text sizes and using
contrasting colors. The higher the contrast between
features, the more some features will stand out (usually
those that are bigger, darker, or brighter). Conversely, low
visual contrast can be used to promote a more subtle
impression, and lower contrast maps can be used as
basemaps on which thematic operational layers can be
overlaid.
Although black and white provides the best visual contrast between colors, this is not
always the best color choice for maps.
When using colors of similar high (shown here) or low (shown below) saturation
(brightness), the hues (red, green, blue, yellow) must be distinguishable. If not,
varying the saturation or value (lightness or darkness) of a color can also create
contrast. Line and symbol casings and text masks can help as well.
22/09/26, 10:57
Primary Design Principles for Cartography
https://www.esri.com/arcgis-blog/products/arcgis-pro/mapping/primary-design-principles-for-cartography
3
/
10
Low visual contrast works best for basemaps so that the overlaid thematic layers are
more visually prominent.
3. Figure-Ground
Figure-ground organization, or figure-ground for short, is
the spontaneous separation of the primary area of interest
in the foreground (the figure) from an amorphous
background. Cartographers use this design principle to
help readers focus on a specific area of the map. There are
many ways to promote figure-ground, such as showing the
map as a closed form that only includes the figure, or using
the techniques illustrated with the above map of Botswana.
Some of the techniques can be used together, and other
techniques allow you to highlight your area of interest.
No figure-ground organization (left) and a closed form (right).
ArcGIS Blog
Overview
Topics
Search ArcGIS Blog
22/09/26, 10:57
Primary Design Principles for Cartography
https://www.esri.com/arcgis-blog/products/arcgis-pro/mapping/primary-design-principles-for-cartography
4
/
10
A drop shadow (left) and screening (right).
Illumination (left) and a vignette (right).
4. Visual Hierarchy
Visual hierarchy is the internal graphic organization or
structure of the content in a map. Visual hierarchy helps
cartographers communicate the relative importance of
mapped features through a visual impression that prioritizes
or orders the categories of features. This visual layering of
information is fundamental to a reader’s ability to
understand a map. Correctly applied, visual hierarchy
reflects an appropriate intellectual order by graphically
emphasizing the most important map features and de-
emphasizing those that are less important.
The hierarchical organization for reference maps (those that
show the location of a variety of physical and cultural
features, such as terrain, roads, boundaries, and
settlements) works differently than for thematic maps (those
that concentrate on the distribution of a single attribute or
the relationship among a few related attributes).
For reference maps, subtle differences order the layers.
Often, the order depends on the way layers occur
22/09/26, 10:57
Primary Design Principles for Cartography
https://www.esri.com/arcgis-blog/products/arcgis-pro/mapping/primary-design-principles-for-cartography
5
/
10
geographically, with physiography on the bottom, followed
by hydrography, vegetation, and human-made features,
then boundaries and administrative features on top. For
thematic maps, reference layers recede to the background,
allowing the thematic layer to ascend to a higher visual
plane. Labels remain on the highest visual plane to ensure
legibility.
In reference maps, different colors, patterns, and sizes for the text and symbols help
distinguish among features on the same layer and between layers. Overlaying one
layer atop another provides the subtle separation needed to understand the
hierarchy of feature layers. (Reference map segment courtesy of Land Information
New Zealand.)
When mapping thematic data, the base layer content is kept to a minimum so that
the thematic layer lies on the highest visual plane in the hierarchy.
5. Proportion
22/09/26, 10:57
Primary Design Principles for Cartography
https://www.esri.com/arcgis-blog/products/arcgis-pro/mapping/primary-design-principles-for-cartography
6
/
10
Proportion helps the map and its elements come together
as a cohesive whole to form an aesthetically pleasing
visualization. Proportion is the relationship between one
element and another in the map and on the layout. Design
concepts that relate to proportion include symmetry,
balance, and harmony.
Balance is the distribution of visual weight within a map or
on a layout. The impression of visual balance is controlled
by the size, visual weight, and location of the contents in the
map and the elements on the layout. Visual balance can be
promoted by placing the map figure in the visual center of
the layout, which is a point just above the geometric center.
This is the point on which the eye first focuses, and it serves
as the fulcrum, or balancing point, for the layout. The visual
center of the whole image shifts as changes are made to the
elements on the layout.
On layout at the left, the map is positioned at the visual center of the layout, and map
elements are arranged in a symmetrical manner to create formal balance. The other
two layouts (middle and right) are designed with informal balance. The position of
elements on the layout can also cause the eye to move in a desired direction, for
example, from the title to the map to the other elements on the page.
When a layout has harmony, the map and its elements have
a cohesive arrangement and present a meaningful whole.
Harmony can be promoted through alignment and
distribution. Alignment positions elements relative to each
other (left, center, right, top, bottom). Distribution spaces
elements evenly between each other. Both can be
employed with objects within elements, such as the parts of
a legend, or with a set of related elements, such as the
locator map, text block, and legend in the layout of a map of
the US below.
22/09/26, 10:57
Primary Design Principles for Cartography
https://www.esri.com/arcgis-blog/products/arcgis-pro/mapping/primary-design-principles-for-cartography
7
/
10
Symmetry, balance, and harmony work together to promote good proportion.
To learn more about these and other design principles for
cartography, see 
, from Esri Press.
Share this article
Dr. Aileen Buckley is a cartographer researcher and Senior Principal GIS Engineer at Esri. I'm on the ArcGIS Living Atlas of the World Team,
making, writing, and talking about maps. I'm also involved in a number of cartographic societies and association, and I'm the chair of the
ICA Ethics in Cartography Commission.
ARTICLE DISCUSSION:
Map Use: Map Reading and Design,
Volume 1, ninth edition
mapping
cartogaraphy
cartographic design principles
cartography
principles of cartography
principles of map design
arcgis online
arcgis pro
Aileen Buckley
22/09/26, 10:57
Primary Design Principles for Cartography
https://www.esri.com/arcgis-blog/products/arcgis-pro/mapping/primary-design-principles-for-cartography
8
/
10
Leave a Reply
You must be 
logged in
 to post a comment.
ARCGIS
COMMUNITY
UNDERSTANDING GIS
COMPANY
SPECIAL PROGRAMS
ArcGIS Overview
Mapping
ArcGIS Pro
ArcGIS Enterprise
ArcGIS Online
Developer Technology
ArcGIS Location Platform
Esri Store
ArcGIS Architecture Center
Esri Community
ArcGIS Blog
Industry Blog
User Research and Testing
Esri Young Professionals Network
Events
AI Assistant (Beta)
What is GIS?
Location Intelligence
Training
ArcNews
ArcWatch
Esri Press
Esri Videos
GIS Dictionary
About Esri
Contact Us
Careers
Open Vision
Partners
Code of Business Conduct
Environmental & Sustainability Initiatives
Sitemap
ArcGIS for Personal Use
ArcGIS for Student Use
22/09/26, 10:57
Primary Design Principles for Cartography
https://www.esri.com/arcgis-blog/products/arcgis-pro/mapping/primary-design-principles-for-cartography
9
/
10
Conservation
Disaster Response
Education
Nonprofit
Racial Equity
Privacy
Accessibility
Legal
Web Terms of Use
Trust Center
Manage Cookies
Do Not Share My Personal Information
22/09/26, 10:57
Primary Design Principles for Cartography
https://www.esri.com/arcgis-blog/products/arcgis-pro/mapping/primary-design-principles-for-cartography
10
/
10
