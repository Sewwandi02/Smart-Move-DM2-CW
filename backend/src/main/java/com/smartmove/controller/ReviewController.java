package com.smartmove.controller;

import com.smartmove.model.Review;
import com.smartmove.repository.ReviewRepository;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/v1/reviews")
@CrossOrigin(origins = "*")
public class ReviewController {

    private final ReviewRepository reviewRepository;

    public ReviewController(ReviewRepository reviewRepository) {
        this.reviewRepository = reviewRepository;
    }

    @GetMapping("/route/{routeId}")
    public List<Review> getReviewsByRoute(@PathVariable String routeId) {
        return reviewRepository.findByRouteId(routeId);
    }

    @GetMapping("/complaints")
    public List<Review> searchComplaints(@RequestParam(defaultValue = "delay|AC") String keyword) {
        return reviewRepository.searchComplaintsByKeyword(keyword);
    }
}