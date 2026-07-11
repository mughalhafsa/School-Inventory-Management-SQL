**School Inventory Management System | SQL Portfolio Project**
   
**Problem Statement**
Asas International School managed 1000+ assets across 6 branches with no central digital system.
Before this system:
1. Tracking was entirely manual and paper-based
2. Monthly reconciliation took 2 full days every month
3. No visibility into asset location, movement, or consumption
4. No way to identify which staff member had which asset
5. Consumable items (stationery, janitorial, grocery) had no reorder alerts
6. Purchase history had no vendor linkage or audit trail

**My Role**
As Business Systems Analyst & IT Incharge at Asas International School, I:
1. Conducted gap analysis and stakeholder interviews across all departments
2. Defined system logic — categories, locations, transaction types, and report formats
3. Designed complete functional flow and data structure specifications
4. Coordinated with the development team through detailed written specifications
5. Led 3-month UAT at the pilot branch — identifying and resolving bugs and workflow gaps
Rolled out the system across 6 branches

_Note: This SQL project is a database reimplementation of that real system,
built with sample data for portfolio demonstration purposes._




**Database Schema
Tables (9)**

1. **staff**	Employee records with department & designation
2. **vendor**	Supplier information and contact details
3. **category**Asset categories (Electrical, IT, Furniture, etc.)
4. **subcategory**	Sub-classifications linked to parent category
5. **location**	Physical locations (Room 1, Room 2, etc.)
6. **sublocation**	Sub-areas within locations (Section 1, Section 2)
7. **purchase**	Purchase records linked to vendor, staff & invoice
8. **material**	Master item registry with price & minimum threshold
9. **material_log**	Full transaction history (Add/Move/Remove/Consume/Issue/Return)
10. **asset_issuance**	Staff-wise asset issue & return tracking

**Views (8**)

1. **current_stock**	Available stock + stock value per item
2. **category_wise_summary**	Active vs inactive materials per category
3. **threshold_alert**	Items below minimum quantity — reorder required
4. **location_stock**Stock quantity per location (Move logic included)
5. **unassigned_materials**	Items added but no location assigned (Inactive)
6. **staff_asset_dashboard**	Which staff has which asset issued
7. **purchase_history**	Full vendor-wise purchase trail with invoice
8. **weekly_comparison**	This week vs last week stock movement (dynamic dates)

**Technical Features**

1. **ENUM** for action_type	Enforces only valid transaction types
2. **AUTO_INCREMENT PKs**	Clean, auto-managed primary keys
3. **UNIQUE** constraint on material	Prevents duplicate items per category
4. **CHECK** constraints	quantity > 0, price >= 0, minimum_quantity >= 0
5. **ON DELETE CASCADE / SET NULL**	Referential integrity across all tables
6. **8 Indexes**	Optimized query performance on high-use columns
7. **source_location_id**	Tracks Move transactions — deducts from origin, adds to destination
8. **DATEDIFF & DATE_SUB**	Dynamic time-based analysis without hardcoded dates
9. **CASE WHEN**	Flexible stock calculations across all action types
10. **COALESCE**Handles NULL values gracefully in reports

**Transaction Types**

1. **Add**	New item added to inventory at a location
2. **Move**	Item moved from one location to another
3. **Remove**	Item permanently removed (damaged, lost)
4. **Consume**	Consumable item used (stationery, grocery, janitorial)
5. **Issue**	Item issued to a staff member
6. **Return**	Issued item returned by staff member

**Key Insights (from sample data)**
1. Stationery & Janitorial items fall below threshold → reorder required
2. 3 out of 15 materials have no location assigned (Inactive)
3. Marker Pens highest consumption — 49 out of 50 units consumed
4. Office Chair most actively tracked — Add, Move, Consume logs
5. 5 assets currently issued to staff across 3 employees
6. Router Spare — 2 units removed (damaged) visible in audit trail
7. Full purchase trail across 4 vendors with invoice numbers
   
**Business Impact**
Metric | Before |	After
1. **Reconciliation** time	2 days/month |	1 hour/week
2. **Asset visibility**	Zero | 	Real-time across 6 branches
3. **Reorder alerts**	Manual |	Automatic via threshold view
4. **Move tracking**	Not  | tracked	Source + destination logged
5. **Audit trail**	Paper-based	 | Full digital history
6. **Purchase accountability** None	 | Vendor + invoice + staff linked

**Challenges & Learning**
1. Move Logic Tracking moves required source_location_id — without it, stock at origin location would not be deducted, causing incorrect location totals.
2. Issued Items in Stock Calculation Issued items must reduce available stock. The Issue action type in material_log ensures real-time available stock reflects what is actually on shelves.
3. Consumable vs Permanent Assets Consumables (stationery, grocery, janitorial) need threshold alerts and high-frequency tracking. Permanent assets (furniture, IT) need location and issuance tracking. Both handled in one unified schema.
4. Duplicate Prevention UNIQUE (item_name, category_id) composite constraint prevents the same item from being added twice in the same category while allowing same name across different categories.

**How to Run**
1.	Open db-fiddle.com
2.	Select MySQL 8.0
3.	Paste inventory_schema.sql in the Schema SQL box
4.	Click Run
5.	Paste queries in Query SQL box to explore:
   **Quries**
**-- Report 1: Current stock**
SELECT * FROM current_stock ORDER BY category_name, item_name;

**-- Report 2: Category wise summary**
SELECT * FROM category_wise_summary ORDER BY category_name;

**-- Report 3: Location wise stoc**k
SELECT * FROM location_stock ORDER BY location_name, item_name;

**-- Report 4: Threshold alert**
SELECT * FROM threshold_alert ORDER BY category_name;

**-- Report 5: Unassigned materials**
SELECT * FROM unassigned_materials ORDER BY days_unassigned DESC;

**-- Report 6: Staff asset dashboard**
SELECT * FROM staff_asset_dashboard ORDER BY department;

**-- Report 7: Purchase history**
SELECT * FROM purchase_history ORDER BY purchase_date DESC;

**-- Report 8: Weekly comparison**
SELECT * FROM weekly_comparison ORDER BY category_name;

**-- Report 9: Movement history**
SELECT 
    ml.log_id,
    m.item_name,
    c.category_name,
    ml.action_type,
    src.location_name AS from_location,
    dst.location_name AS to_location,
    ml.quantity,
    ml.reason,
    ml.log_date
FROM material_log ml
JOIN material m ON ml.material_id = m.material_id
JOIN category c ON m.category_id = c.category_id
LEFT JOIN location src ON ml.source_location_id = src.location_id
LEFT JOIN location dst ON ml.location_id = dst.location_id
ORDER BY ml.log_date DESC, ml.log_id DESC;

**-- Report 10: Consumed items detail**
SELECT 
    m.item_name,
    c.category_name,
    lo.location_name,
    ml.quantity AS consumed_qty,
    ml.reason,
    ml.log_date
FROM material_log ml
JOIN material m ON ml.material_id = m.material_id
JOIN category c ON m.category_id = c.category_id
JOIN location lo ON ml.location_id = lo.location_id
WHERE ml.action_type = 'Consume'
ORDER BY ml.log_date DESC;

**Files**
File	Description
**inventory_schema.sql**	Complete schema, sample data, indexes & views
**README.md**	Project documentation


