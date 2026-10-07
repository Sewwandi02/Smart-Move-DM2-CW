use("smartmove_db");

// Query 1: Retrieve all passenger reviews for a specific route
db.reviews.find({ route_id: "RT-Colombo-Kandy" });

// Query 2: Identify highest-rated vehicles (Aggregation)
db.reviews.aggregate([
  { $group: { _id: "$vehicle_id", avgRating: { $avg: "$rating" }, totalReviews: { $sum: 1 } } },   {$sort: { avgRating: -1 } }
]);

// Query 3: Identify highest-rated drivers (Aggregation)
db.reviews.aggregate([
  { $group: { _id: "$driver_id", avgRating: { $avg: "$rating" }, totalReviews: { $sum: 1 } } },   {$sort: { avgRating: -1 } }
]);

// Query 4: Keyword complaint search using $regex
db.reviews.find({
  comment: { $regex: "delay\vert{}AC", $options: "i" },
  feedback_type: "complaint"
});

// Query 5: Retrieve vehicle documents & multimedia details
db.vehicle_documents.find(
  { vehicle_id: "VEH-1001" },
  { vehicle_id: 1, plate_number: 1, documents: 1, multimedia: 1 }
);

// Query 6: Custom printed output for complaint reviews
db.reviews.find({ feedback_type: "complaint" }).forEach(c => {
  print(`[${c.review_id}] Route: ${c.route_id} | Rating: ${c.rating}/5 | Passenger: ${c.passenger_id}`);
  print(`   Comment: "${c.comment}"\n`);
});