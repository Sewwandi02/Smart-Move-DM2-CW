// Switch/Create Database
use("smartmove_db");

// Clear existing collections to avoid key conflicts
db.vehicle_documents.drop();
db.reviews.drop();
db.announcements.drop();

// 1. Insert Vehicle Documents & Multimedia Data
db.vehicle_documents.insertMany([
  {
    vehicle_id: "VEH-1001",
    plate_number: "ND-4521",
    model: "Toyota Coaster Bus",
    documents: [
      { doc_type: "Insurance", doc_number: "INS-9921", expiry_date: ISODate("2027-05-10T00:00:00Z"), status: "Valid" },
      { doc_type: "Revenue License", doc_number: "RL-8812", expiry_date: ISODate("2026-12-31T00:00:00Z"), status: "Valid" }
    ],
    multimedia: [
      { type: "image", url: "https://smartmove.lk/media/vehicles/nd4521_front.jpg", tag: "exterior" },
      { type: "image", url: "https://smartmove.lk/media/vehicles/nd4521_interior.jpg", tag: "interior" }
    ],
    created_at: new Date()
  },
  {
    vehicle_id: "VEH-1002",
    plate_number: "WP-6720",
    model: "Nissan Caravan Van",
    documents: [
      { doc_type: "Insurance", doc_number: "INS-4410", expiry_date: ISODate("2027-01-15T00:00:00Z"), status: "Valid" }
    ],
    multimedia: [
      { type: "image", url: "https://smartmove.lk/media/vehicles/wp6720_side.jpg", tag: "exterior" }
    ],
    created_at: new Date()
  }
]);

// 2. Insert Reviews, Ratings, & Complaints Data
db.reviews.insertMany([
  {
    review_id: "REV-501",
    passenger_id: "PASS-102",
    route_id: "RT-Colombo-Kandy",
    vehicle_id: "VEH-1001",
    driver_id: "DRV-201",
    rating: 5,
    feedback_type: "compliment",
    comment: "Very smooth ride and punctual departure!",
    tags: ["punctual", "clean"],
    created_at: new Date()
  },
  {
    review_id: "REV-502",
    passenger_id: "PASS-105",
    route_id: "RT-Colombo-Kandy",
    vehicle_id: "VEH-1001",
    driver_id: "DRV-201",
    rating: 2,
    feedback_type: "complaint",
    comment: "AC delay during peak hour, air conditioning was not working properly.",
    tags: ["AC issue", "delay"],
    created_at: new Date()
  },
  {
    review_id: "REV-503",
    passenger_id: "PASS-210",
    route_id: "RT-Galle-Colombo",
    vehicle_id: "VEH-1002",
    driver_id: "DRV-205",
    rating: 5,
    feedback_type: "compliment",
    comment: "Driver DRV-205 was very courteous and safe.",
    tags: ["safe driving"],
    created_at: new Date()
  }
]);

// 3. Insert Travel Announcements & Notifications
db.announcements.insertMany([
  {
    announcement_id: "ANC-101",
    title: "Route Delay Notice - Expressway",
    message: "Southern Expressway trips delayed by 20 mins due to maintenance.",
    target_routes: ["RT-Galle-Colombo", "RT-Matara-Colombo"],
    type: "delay",
    active: true,
    posted_at: new Date()
  },
  {
    announcement_id: "ANC-102",
    title: "Holiday Schedule Update",
    message: "Special bus schedules operating on upcoming poya day.",
    target_routes: ["RT-Colombo-Kandy"],
    type: "general",
    active: true,
    posted_at: new Date()
  }
]);