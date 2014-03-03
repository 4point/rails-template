<%
  def clean_word(str)
    str1 = 'Admin::'
    str2 = 'admin_'
    str3 = 'Admin'
    str.gsub(str1, '').gsub(str2, '').gsub(str3, '')
  end
-%>
<% if namespaced? -%>
require_dependency "<%= namespaced_file_path %>/application_controller"

<% end -%>
<% module_namespacing do -%>
class <%= controller_class_name %>Controller < <%= if singular_table_name.include?('admin_') then AdminController else ApplicationCntroller end %>
  before_action :set_<%= clean_word singular_table_name %>, only: [:show, :edit, :update, :destroy]

  # GET <%= route_url %>
  def index
    @<%= clean_word plural_table_name %> = <%= clean_word orm_class.all(class_name) %>
  end

  # GET <%= route_url %>/1
  def show
  end

  # GET <%= route_url %>/new
  def new
    @<%= clean_word singular_table_name %> = <%= clean_word orm_class.build(class_name) %>
  end

  # GET <%= route_url %>/1/edit
  def edit
  end

  # POST <%= route_url %>
  def create
    @<%= clean_word singular_table_name %> = <%= clean_word orm_class.build(class_name, "#{singular_table_name}_params") %>

    if @<%= clean_word orm_instance.save %>
      redirect_to <%= singular_table_name %>_path(@<%= clean_word singular_table_name %>.id), notice: <%= "'#{human_name} was successfully created.'" %>
    else
      render action: 'new'
    end
  end

  # PATCH/PUT <%= route_url %>/1
  def update
    if @<%= clean_word orm_instance.update("#{singular_table_name}_params") %>
      redirect_to <%= singular_table_name %>_path, notice: <%= "'#{human_name} was successfully updated.'" %>
    else
      render action: 'edit'
    end
  end

  # DELETE <%= route_url %>/1
  def destroy
    @<%= clean_word orm_instance.destroy %>
    redirect_to <%= table_name %>_path, notice: <%= "'#{human_name} was successfully destroyed.'" %>
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_<%= clean_word singular_table_name %>
      @<%= clean_word singular_table_name %> = <%= clean_word orm_class.find(class_name, "params[:id]") %>
    end

    # Only allow a trusted parameter "white list" through.
    def <%= clean_word "#{singular_table_name}_params" %>
      <%- if attributes_names.empty? -%>
      params[<%= clean_word ":#{singular_table_name}" %>]
      <%- else -%>
      params.require(<%= clean_word ":#{singular_table_name}" %>).permit(<%= attributes_names.map { |name| ":#{name}" }.join(', ') %>)
      <%- end -%>
    end
end
<% end -%>
