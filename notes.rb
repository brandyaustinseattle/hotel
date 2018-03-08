already part of reservation instance
  - start_date
  - end_date

already part of reservation method
  - discount

can add as part of reservation instance
group_name indicates part of block
nil group_name means not part of block
  - group_name

room can have block flag to account for rooms that are part of a block, but not yet reserved


used in create_rooms_block method
  - rooms_needed

* available_date? should exclude blocks
* available_range? should exclude blocks

add method to create_rooms_block in hotel manager
 - dont create reservation, just create block

add method to reserve_room_in_block in hotel manager

add method for find_rooms_in_block (available only) in hotel manager

add instance variable for block? in room

add method for add_to_block in room

add discount as constant in reservation
update find_total_cost to apply discount
