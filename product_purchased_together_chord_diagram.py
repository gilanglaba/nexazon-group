from sqlalchemy import create_engine
import pandas as pd
import holoviews as hv
from holoviews import opts
from holoviews import dim
hv.extension('bokeh')

DATABASE_URL = "postgresql://postgres:password@postgres:5432/dbdm"
engine = create_engine(DATABASE_URL)

query = """
SELECT 
    split_part(product_pair, '-', 1) AS product_1,
    split_part(product_pair, '-', 2) AS product_2,
    times_purchased_together
FROM (
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
)
limit 10;
"""
df = pd.read_sql(query, engine)

df.columns = ['product_1', 'product_2', 'times_purchased_together']  # Example column names

# Create list of tuples for Chord Diagram
edges = list(zip(df['product_1'], df['product_2'], df['times_purchased_together']))

# Create Chord object
chord = hv.Chord(edges)

# Customize appearance
chord.opts(
opts.Chord(labels='name', edge_color=hv.dim('product_1').str(), 
               node_color=hv.dim('product_2').str(), cmap='Category20', 
               edge_cmap='coolwarm', edge_line_width=hv.dim('times_purchased_together')*0.1, 
               width=800, height=800)
)

# Show the Chord Diagram
chord