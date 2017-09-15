request = require("./request")
settings = require("settings-sharelatex")
{db, ObjectId} = require("../../../../app/js/infrastructure/mongojs")

count = 0

class User
	constructor: (options = {}) ->
		@email = "acceptance-test-#{count}@example.com"
		@password = "acceptance-test-#{count}-password"
		count++
		@jar = request.jar()
		@request = request.defaults({
			jar: @jar
		})

	login: (callback = (error) ->) ->
		@getCsrfToken (error) =>
			return callback(error) if error?
			@request.post {
				url: "/register" # Register will log in, but also ensure user exists
				json:
					email: @email
					password: @password
			}, (error, response, body) =>
				return callback(error) if error?
				db.users.findOne {email: @email}, (error, user) =>
					return callback(error) if error?
					@id = user?._id?.toString()
					@_id = user?._id?.toString()
					@first_name = user?.first_name
					@referal_id = user?.referal_id
					callback()

	logout: (callback = (error) ->) ->
		@getCsrfToken (error) =>
			return callback(error) if error?
			@request.get {
				url: "/logout"
				json:
					email: @email
					password: @password
			}, (error, response, body) =>
				return callback(error) if error?
				db.users.findOne {email: @email}, (error, user) =>
					return callback(error) if error?
					@id = user?._id?.toString()
					@_id = user?._id?.toString()
					callback()

	ensure_admin: (callback = (error) ->) ->
		db.users.update {_id: ObjectId(@id)}, { $set: { isAdmin: true }}, callback

	upgradeFeatures: (callback = (error) -> ) ->
		features = {
			collaborators: -1 # Infinite
			versioning: true
			dropbox:true
			compileTimeout: 60
			compileGroup:"priority"
			templates: true
			references: true
			trackChanges: true
			trackChangesVisible: true
		}
		db.users.update {_id: ObjectId(@id)}, { $set: { features: features }}, callback

	downgradeFeatures: (callback = (error) -> ) ->
		features = {
			collaborators: 1
			versioning: false
			dropbox:false
			compileTimeout: 60
			compileGroup:"standard"
			templates: false
			references: false
			trackChanges: false
			trackChangesVisible: false
		}
		db.users.update {_id: ObjectId(@id)}, { $set: { features: features }}, callback

	defaultFeatures: (callback = (error) -> ) ->
		features = settings.defaultFeatures
		db.users.update {_id: ObjectId(@id)}, { $set: { features: features }}, callback

	full_delete_user: (email, callback = (error) ->) ->
		db.users.findOne {email: email}, (error, user) =>
			if !user?
				return callback()
			user_id = user._id
			db.projects.remove owner_ref:ObjectId(user_id), {multi:true}, (err)->
				if err? 
					callback(err)
				db.users.remove {_id: ObjectId(user_id)}, callback

	createProject: (name, callback = (error, project_id) ->) ->
		@request.post {
			url: "/project/new",
			json:
				projectName: name
		}, (error, response, body) ->
			return callback(error) if error?
			if !body?.project_id?
				console.error "SOMETHING WENT WRONG CREATING PROJECT", response.statusCode, response.headers["location"], body
			callback(null, body.project_id)

	deleteProject: (project_id, callback=(error)) ->
		@request.delete {
			url: "/project/#{project_id}"
		}, (error, response, body) ->
			return callback(error) if error?
			callback(null)

	openProject: (project_id, callback=(error)) ->
		@request.get {
			url: "/project/#{project_id}"
		}, (error, response, body) ->
			return callback(error) if error?
			if response.statusCode != 200
				err = new Error("Non-success response when opening project: #{response.statusCode}")
				return callback(err)
			callback(null)

	addUserToProject: (project_id, email, privileges, callback = (error, user) ->) ->
		@request.post {
			url: "/project/#{project_id}/users",
			json: {email, privileges}
		}, (error, response, body) ->
			return callback(error) if error?
			callback(null, body.user)

	makePublic: (project_id, level, callback = (error) ->) ->
		@request.post {
			url: "/project/#{project_id}/settings/admin",
			json:
				publicAccessLevel: level
		}, (error, response, body) ->
			return callback(error) if error?
			callback(null)

	getCsrfToken: (callback = (error) ->) ->
		@request.get {
			url: "/register"
		}, (err, response, body) =>
			return callback(error) if error?
			csrfMatches = body.match("window.csrfToken = \"(.*?)\";")
			if !csrfMatches?
				return callback(new Error("no csrf token found"))
			@csrfToken = csrfMatches[1]
			@request = @request.defaults({
				headers:
					"x-csrf-token": @csrfToken
			})
			callback()

	changePassword: (callback = (error) ->) ->
		@getCsrfToken (error) =>
			return callback(error) if error?
			@request.post {
				url: "/user/password/update"
				json:
					currentPassword: @password
					newPassword1: @password
					newPassword2: @password
			}, (error, response, body) =>
				return callback(error) if error?
				db.users.findOne {email: @email}, (error, user) =>
					return callback(error) if error?
					callback()

	getUserSettingsPage: (callback = (error, statusCode) ->) ->
		@getCsrfToken (error) =>
			return callback(error) if error?
			@request.get {
				url: "/user/settings"
			}, (error, response, body) =>
				return callback(error) if error?
				callback(null, response.statusCode)

	getProjectListPage: (callback=(error, statusCode)->) ->
		@getCsrfToken (error) =>
			return callback(error) if error?
			@request.get {
				url: "/project"
			}, (error, response, body) =>
				return callback(error) if error?
				callback(null, response.statusCode)



module.exports = User
