class @AppUtils

	@isEmptyData: ( data ) ->
		return (not data) or (data is undefined) or (data is "") or (data.length is 0)