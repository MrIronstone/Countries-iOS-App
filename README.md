# Countries iOS App

The project I developed a countries ios application to learn CoreData, UIKit, Swift and networking.

List countries and can save countries to the database. When clicked on any country, there is a detailed view that shows flag, country code and button for wiki page

The app has 2 tab, one is "Main" tab that list coutries and the other is "Saved" to show saved countries




### *App demo*
<video src="https://user-images.githubusercontent.com/47990723/193879883-b7cad5d4-45b0-4c78-bcd4-31b1f8325810.mp4" controls="controls" style="max-width: 730px;"> </video>

### *Demo Highlights*
• Detail view properly handles the situation where the some details are not provided by the API. <br /><br />
• Used **CoreData** to store country informations when tapped on star icon <br /><br />
• All country datas provided by https://wft-geo-db.p.rapidapi.com API. <br/><br/>
• When any country is saved or removed, it notifies the saved screen via swift's own Notification Center, and all the data that makes up the page and cells are recalculated. <br/><br/>

### *Code Highlights*
• Swift itself is unable to load SVG images to IUImage so I had to use external library such as SVGKit  <br /><br />
• Uses Swift's Result type <br /><br />
• Every view has been created ***programmatically*** <br /><br />
• • Every view has been created ***programmatically*** <br /><br />
• Each page loads 10 countries, thanks to the "limit 10" parameter in the network layer. 
When it comes to the bottom of the page, it automatically pulls the other page from the internet and merges it with the previous one. 
This way, both the pages contain little data and the next page can be loaded quickly and I get a fluent experience on UI. <br /><br /> <br /><br />

### *Used UIKit Components*
• CollectionView <br /><br />
• UINavigationController <br /><br />
• UITabBarController <br /><br />
• CoreData <br /><br />
