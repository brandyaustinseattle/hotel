1. What classes does each implementation include? Are the lists the same?

A and B both include CartEntry, ShoppingCart, and Order. They are the same.


2. Write down a sentence to describe each class.

CartEntry manages the price and quantity of items.
ShoppingCart keeps track of all entries in the cart.
Order creates a cart and calculates the total.


3. How do the classes relate to each other? It might be helpful to draw a diagram on a whiteboard or piece of paper.

In A, a CartEntry represents the price and quantity of an item that will be entered in the cart. ShoppingCart keeps track of the collection of entries that have been added to the cart. And Order, creates the cart itself and calculates the total_price.

In B, the classes do the same thing, but the functions work a little differently. The price for an entry is calculated in CartEntry which makes it possible for ShoppingCart to sum the prices of all entries by calling that method. Order then adds the sales tax to these calculations.


4. What data does each class store? How (if at all) does this differ between the two implementations?

In both A and B, CartEntry stores unit_price and quantity, ShoppingCart stores entries, and Order keeps track of the cart. In A, all price related calculations occur in Order. In B, price is calculated in CartEntry, sum in ShoppingCart, and total price in Order.


5. What methods does each class have? How (if at all) does this differ between the two implementations?

In A, the Order class has a total_price function. In B, CartEntry and ShoppingCart have a price function and Order has a total_price function. The only other methods are the initialize ones.


6. Consider the Order#total_price method. In each implementation:

a. Is logic to compute the price delegated to "lower level" classes like ShoppingCart and CartEntry, or is it retained in Order?
In A, all of the logic is retained in Order. In B, it’s delegated to other classes - CartEntry finds the price of a particular number of items, ShoppingCart, sums the prices of each entry, and Order adds the sales tax.

b. Does total_price directly manipulate the instance variables of other classes?
In A, total_price calls entries, entry.unit_price, and entry.quantity which are the instance variables of other classes. It uses unit_price and entry_quantity to calculate the sum. In B, total_price uses cart.price which merely refers to the price method in ShoppingCart. Overall, A manipulates the instance variables of other classes, while B does not.


7. If we decide items are cheaper if bought in bulk, how would this change the code? Which implementation is easier to modify?
In A, you would need to add a variable that indicates if something is bought in bulk. Or, alternatively, add logic to Order that responds differently depending on quantity.

In B, you could edit the price function in CartEntry and not make any other changes. With this option, CartEntry would know that items are cheaper bought in bulk, but other classes wouldn’t be informed of the change. This would be the easiest way to modify the code.


8. Which implementation better adheres to the single responsibility principle?

B better adheres to the single responsibility principle because it only knows the minimum information needed about other classes. They trust the other classes to pass along the appropriate details so that it only has to do it’s one responsibility.


9. Bonus question once you've read Metz ch. 3: Which implementation is more loosely coupled?

B is more loosely coupled because each class only knows what it needs to know. This is preferable because you can edit parts of the code in fewer places whenever a change is required.
