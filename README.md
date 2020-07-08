## The objective of this Case is to Predication of bike rental count on daily based on the environmental and seasonal settings.

### The details of data attributes in the dataset are as follows -

|Sr. No. |Attributes | Description |
|---|---|---|
|1. |instant| Record index|
|2. |dteday| Date|
|3. |season| Season (1:springer, 2:summer, 3:fall, 4:winter)|
|4. |yr| Year (0: 2011, 1:2012)|
|5. |mnth| Month (1 to 12)|
|6. |hr| Hour (0 to 23)|
|7. |holiday| weather day is holiday or not (extracted fromHoliday Schedule)|
|8. |weekday| Day of the week|
|9. |workingday| If day is neither weekend nor holiday is 1, otherwise is 0|
|10. |weathersit| (extracted fromFreemeteo)|
|   |Option 1: |Clear, Few clouds, Partly cloudy, Partly cloudy|
|   |Option 2: |Mist + Cloudy, Mist + Broken clouds, Mist + Few clouds, Mist|
|   |Option 3: |Light Snow, Light Rain + Thunderstorm + Scattered clouds, Light Rain + Scattered clouds|
|   |Option 4: |Heavy Rain + Ice Pallets + Thunderstorm + Mist, Snow + Fog|
|11. |temp| Normalized temperature in Celsius. The values are derived via (t-t_min)/(t_max-t_min), t_min=-8, t_max=+39 (only in hourly scale)|
|12. |atemp| Normalized feeling temperature in Celsius. The values are derived via(t-t_min)/(t_maxt_min), t_min=-16, t_max=+50 (only in hourly scale)|
|13. |hum| Normalized humidity. The values are divided to 100 (max)|
|14. |windspeed| Normalized wind speed. The values are divided to 67 (max)|
|15. |casual| count of casual users|
|16. |registered| count of registered users|
|17. |cnt| count of total rental bikes including both casual and registered|

### Phases of project

- Exploratory Data Analysis
   - Missing Value Analysis
   - Outlier Analysis
   - Feature Selection
   - Feature Scaling
- Splitting train and test dataset in 80:20 ratio
- Applying various model on our processed dataset
    - Decision Tree Regressor
    - Random Forest Regressor
    - Linear Regression
- Hyper Parameter Tuning
- Validation metrics used to check accuracy of model is Mean Absolute Error (MAE) and Root Mean Square Error (RMSE)

|Model | MAPE | RMSE |SELECTED |
|---|---|---|---|
|Decision Tree Regressor | 17.34 | 742.50 | |
|Random Forest Regressor| 13.51 | 565.70 | Yes |
|Linear Regression| 30.66 | 1316.98 | |

### As the MAPE score of Random forest is good as compared to other models, Random Forest Regressor is finalized for the given dataset
