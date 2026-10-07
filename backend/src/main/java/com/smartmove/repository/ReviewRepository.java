package com.smartmove.repository;

import com.smartmove.model.Review;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ReviewRepository extends MongoRepository<Review, String> {

    List<Review> findByRouteId(String routeId);

    @Query("{ 'feedback_type': 'complaint', 'comment': { $regex: ?0, $options: 'i' } }")
    List<Review> searchComplaintsByKeyword(String keywordPattern);
}