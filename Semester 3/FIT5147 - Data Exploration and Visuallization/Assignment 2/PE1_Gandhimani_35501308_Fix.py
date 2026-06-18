import pandas as pd

df = pd.read_csv('ALA_S12026PE1.csv')
print(f"Original shape: {df.shape}")
# Confirm the records before removing
invalid_coords = df[df['decimalLongitude'] > 154]
print("Records to remove:")
print(invalid_coords[['observationDate', 'stateProvince', 
                        'decimalLatitude', 'decimalLongitude', 
                        'basisOfRecord', 'dataResourceName']])

# Remove them
df = df[df['decimalLongitude'] <= 154]
print(f"Shape after Fix 1: {df.shape}")
# Should be 25273 rows (removed 3)


# Confirm the record before fixing
mismatch = df[(df['dataResourceUid'] == 'dr1411') & 
              (df['dataResourceName'] == 'eBird Australia')]
print("Record to fix:")
print(mismatch[['dataResourceUid', 'dataResourceName', 
                'observationDate', 'stateProvince']])

# Fix it
df.loc[(df['dataResourceUid'] == 'dr1411') & 
       (df['dataResourceName'] == 'eBird Australia'), 
       'dataResourceName'] = 'iNaturalist Australia'

# Verify
print("dr1411 names after fix:")
print(df[df['dataResourceUid'] == 'dr1411']['dataResourceName'].value_counts())
# Should show only iNaturalist Australia: 587

# Confirm the record
wrong_state = df[(df['stateProvince'] == 'New South Wales') & 
                 (df['decimalLatitude'] < -38)]
print("Record to fix:")
print(wrong_state[['observationDate', 'stateProvince', 
                    'decimalLatitude', 'decimalLongitude', 
                    'dataResourceName', 'basisOfRecord']])

# Fix it using the recordID for precision
target_id = '6a621dc2-f4a0-4e93-9b54-9520a650da33'
df.loc[df['recordID'] == target_id, 'stateProvince'] = 'Tasmania'

# Verify
print("Confirmed fix:")
print(df[df['recordID'] == target_id][['stateProvince', 
                                        'decimalLatitude', 
                                        'decimalLongitude']])

df.to_csv('ALA_S12026PE1_cleaned.csv', index=False)
print(f"Cleaned file saved. Final shape: {df.shape}")