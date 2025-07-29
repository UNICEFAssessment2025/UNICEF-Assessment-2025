

			/**********************************************************************
			*  user_profile.do
			*  Purpose: Configure Stata environment for reproducible analysis
			*  Project: UNICEF-Assessment-2025
			***********************************************************************/

			*-------------------------------
			* 1. Set version control
			*-------------------------------
			version 17.0

			*-------------------------------
			* 2. Clear environment
			*-------------------------------
			clear all
			set more off

			*-------------------------------
			* 3. Set working directory
			*-------------------------------
			* cd "C:\path\to\UNICEF-Assessment-2025" /* Update path */

			*-------------------------------
			* 4. Set graphics and output preferences
			*-------------------------------
			set scheme s1color                // Set graph style
			graph set window fontface "Arial" // Set font for graphs
			set graphics on                   // Enable graphics

		 
		 
			**********************************************************************
			*  End of user_profile.do
			***********************************************************************/
 