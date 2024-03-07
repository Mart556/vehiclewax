# vehiclewax
 Vehicle wax system for owned vehicles.

So the wax can be applied only to owned vehicles stored in a database. The owned vehicles table should have a `wax` table to store the Unix timestamp.
I have included the `db.sql` file for qb and esx.

To apply wax you have to create items in ox_inventory. The example is in `config.lua`.

To vehicle have the wax after taken from the garage you need to add a server export `exports.vehiclewax:EnsureVehicleWax(vehicleEntity)` after it has been spawned.
Example ![image](https://github.com/Mart556/vehiclewax/assets/49863634/c13cd18a-8886-4d6b-8a96-d712b6e431f1)
