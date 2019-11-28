package.path = package.path..";../?.lua";

local SplayTree = require("splaytree")



local st = SplayTree();
local root = nil

local function initTree(st)
    local  vector = {9,8,7,6,5,4,3,2,1,0};
    local length = #vector

    for i = 1, length do
        root = st:insert(vector[i], root);
    end
end

local function test_inorder()
    io.write("\nInOrder: \n");
    st:inOrder(root);
end

local function test_input()

    local input, choice;

    while true do
        io.write("\nSplay Tree Operations\n");
        print("1. Insert ");
        print("2. Delete");
        print("3. Search");
        print("4. Exit");
        io.write("Enter your choice: ");
        choice = io.read()

        print(type(choice), choice)
--[[
        if choice == 1 then
            io.write("Enter value to be inserted: ");
            cin>>input;
            root = st.Insert(input, root);
            io.write("\nAfter Insert: ", input,'\n');
            st:inOrder(root);
            break;
        elseif choice == 2 then
            io.write("Enter value to be deleted: ");
            cin>>input;
            root = st.Delete(input, root);
            io.write("\nAfter Delete: ", input, '\n');
            st:inOrder(root);
            break;
        elseif choice == 3 then
            io.write("Enter value to be searched: ");
            cin>>input;
            root = st.Search(input, root);
            io.write("\nAfter Search ", input, '\n');
            st:inOrder(root);
            break;
        elseif choice == 4 then
            return 1;
        else
            io.write("\nInvalid type! \n");
        end
--]]
    end

    print()
end

initTree(st)
test_inorder()
test_input()




