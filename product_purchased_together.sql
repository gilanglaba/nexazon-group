SELECT 
    CASE 
        WHEN p1.Product_name < p2.Product_name 
        THEN CONCAT(p1.Product_name, ' - ', p2.Product_name)
        ELSE CONCAT(p2.Product_name, ' - ', p1.Product_name)
    END AS product_pair,
    COUNT(*) AS times_purchased_together
FROM Order_Detail od1
JOIN Order_Detail od2 ON od1.Order_ID = od2.Order_ID AND od1.Product_ID < od2.Product_ID
JOIN Product p1 ON od1.Product_ID = p1.Product_ID
JOIN Product p2 ON od2.Product_ID = p2.Product_ID
GROUP BY product_pair
ORDER BY times_purchased_together DESC