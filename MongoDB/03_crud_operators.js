use("smartmove_db");

// 1. Query with $or and $in operators
db.reviews.find({
  $or: [
    { rating: { $in: [1, 2] } },
    { feedback_type: "complaint" }
  ]
});

// 2. Update One Document
db.announcements.updateOne(
  { announcement_id: "ANC-101" },
  { $set: { active: false } }
);

// 3. Update Multiple Documents
db.reviews.updateMany(
  { rating: 5 },
  { $addToSet: { tags: "top_rated" } }
);

// 4. Delete One Document
db.reviews.deleteOne({ review_id: "REV-502" });